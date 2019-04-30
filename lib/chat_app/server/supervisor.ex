defmodule ChatApp.Server.Supervisor do
  alias ChatApp.Server

  def start do
    config = Application.get_env(:chat_app, :server)

    children = [
      {Server, config}
    ]

    opts = [strategy: :one_for_one, name: ChatApp.ServerSupervisor]
    Supervisor.start_link(children, opts)
  end
end
