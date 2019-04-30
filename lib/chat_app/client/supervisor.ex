defmodule ChatApp.Client.Supervisor do
  alias ChatApp.Client

  def start(opts) do
    config = Application.get_env(:chat_app, :server)

    children = [
      {Client, config ++ opts}
    ]

    opts = [strategy: :one_for_one, name: ChatApp.ClientSupervisor]
    Supervisor.start_link(children, opts)
  end
end
