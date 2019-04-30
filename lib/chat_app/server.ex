defmodule ChatApp.Server do
  use GenServer

  require Logger

  alias ChatApp.Server

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(port: port) do
    opts = [{:port, port}]

    {:ok, pid} = :ranch.start_listener(:chat_app, :ranch_tcp, opts, Server.Connection, [])

    Logger.info("Accepting connections on port #{port}")

    {:ok, pid}
  end
end
