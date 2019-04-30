defmodule ChatApp.Client do
  use GenServer

  def start_link(opts) do
    IO.inspect(opts)
    GenServer.start_link(__MODULE__, opts, name: ClientGenserver)
  end

  def init(port: port, host: host) do
    {:ok, host} = :inet.parse_address(to_charlist(host))
    {:ok, socket} = :gen_tcp.connect(host, port, [])

    {:ok, %{socket: socket}}
  end

  def handle_info({:tcp, _socket, data}, state) do
    data
    |> to_string
    |> String.trim()
    |> IO.puts()

    {:noreply, state}
  end

  def handle_cast({:push, data}, %{socket: socket} = state) do
    :gen_tcp.send(socket, data)
    {:noreply, state}
  end
end
