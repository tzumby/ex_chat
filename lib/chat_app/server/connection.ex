defmodule ChatApp.Server.Connection do
  use GenServer

  require Logger

  @default_channel "lobby"

  @doc """
  This implements the ranch_protocol behaviour that expects a start_link/4 for the callback module.
  Spawns an new process to handle the connection. Using :proc_lib to spawn this as per ranch's docs (special process)
  https://ninenines.eu/docs/en/ranch/1.2/guide/protocols/
  """
  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  def init(opts), do: {:ok, opts}

  @doc """
  The special process for handling the connections don't return from start_link until the init function returns.
  This means you can't acknowledge the connection from the init callback. This is why :gen_server.enter_loop/3 is 
  used: starts the process normally and then performs any needed operations before executing the gen_server loop.
  """
  def init(ref, socket, transport) do
    peername = stringify_peername(socket)

    Logger.info("Peer #{peername} connecting")

    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])

    :gen_server.enter_loop(__MODULE__, [], %{
      socket: socket,
      transport: transport,
      peername: peername,
      channel: @default_channel
    })
  end

  def handle_call(:get_client, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:change_nickname, nickname}, state) do
    {:noreply, Map.put(state, :peername, nickname)}
  end

  def handle_cast({:join_channel, channel}, state) do
    {:noreply, Map.put(state, :channel, channel)}
  end

  def handle_info(
        {:tcp, _, message},
        %{transport: transport, peername: peername, channel: channel} = state
      ) do
    message =
      cond do
        Regex.match?(~r/\/nick/, String.trim(message)) ->
          [_match, nickname] = Regex.scan(~r/\/nick\s(.*)/, String.trim(message)) |> List.first()
          GenServer.cast(self(), {:change_nickname, nickname})
          "\nChanged their nickname to #{nickname}\n"

        Regex.match?(~r/\/join/, String.trim(message)) ->
          [_match, channel] = Regex.scan(~r/\/join\s(.*)/, String.trim(message)) |> List.first()
          GenServer.cast(self(), {:join_channel, channel})
          "\n#{peername} joined channel: #{channel}\n"

        true ->
          message
      end

    case channel do
      "" ->
        transport
        |> broadcast(message, state)

      channel ->
        transport
        |> broadcast(message, state, channel)
    end

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, %{peername: peername} = state) do
    Logger.info("Peer #{peername} disconnected")
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _, reason}, %{peername: peername} = state) do
    Logger.info("Error with peer #{peername}: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  @doc """
  ranch:procs(name, connections) returns a list of pids for all processes with active connections. 
  We use the pid to call get_client on the handler process and get the socket for each client.
  We need the sockets to broadcast messages to.
  """
  defp broadcast(transport, message, %{peername: peername}, channel_broadcast \\ @default_channel) do
    :ranch.procs(:chat_app, :connections)
    |> Enum.each(fn conn ->
      if conn != self() do
        %{socket: socket, channel: channel} = GenServer.call(conn, :get_client)

        if channel_broadcast == channel do
          transport.send(socket, "[#{channel}] #{peername}> #{message}")
        end
      end
    end)
  end

  defp stringify_peername(socket) do
    {:ok, {addr, port}} = :inet.peername(socket)

    address =
      addr
      |> :inet_parse.ntoa()
      |> to_string()

    "#{address}:#{port}"
  end
end
