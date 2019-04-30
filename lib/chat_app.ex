defmodule ChatApp do
  require Logger

  alias ChatApp.{Server, Client, ASCII3D}

  def main(argv) do
    argv
    |> parse_args
    |> IO.inspect()
  end

  def run(argv) do
    parse_args(argv)
  end

  def parse_args(argv) do
    parse =
      OptionParser.parse(argv,
        strict: [server: :boolean, client: :boolean, help: :boolean, host: :string],
        aliases: [s: :server, c: :client, h: :host]
      )

    case parse do
      {[server: true], _, _} ->
        {:ok, _pid} = Server.Supervisor.start()
        loop()

      {[client: true], _, _} ->
        {:ok, _pid} = Client.Supervisor.start(host: "0.0.0.0")
        banner()
        receive_command()

      {[client: true, host: host], _, _} ->
        {:ok, _pid} = Client.Supervisor.start(host: host)
        banner()
        receive_command()

      _ ->
        IO.puts("\nUsage:\tchat_app\t[OPTIONS]\n")
        IO.puts("A chat application written in Elixir\n")
        IO.puts("Options:")
        IO.puts("-s,\t--server\tStart the chat server")
        IO.puts("-c,\t--client\tStart the chat client")
        IO.puts("-h,\t--host\tServer ip address\n")
    end
  end

  defp loop(), do: loop()

  defp receive_command do
    IO.gets("> ")
    |> execute_command()
  end

  defp execute_command(data) do
    GenServer.cast(ClientGenserver, {:push, data})
    receive_command()
  end

  defp banner do
    data = "1 12_4 2_1\n1/B2 9_1B2 1/2B 3 2_18 2_1\nB2 B8_1/ 3 B2 1/B_B4 2_6 2_2 1/B_B6 4_1
3 B7 B2/_2 1/2B_1_2 1/B_B B2/_4 1/ 3_1B\n 2 B2 6_1B3 3 B2 1/B2 B1/_/B_B3/ 2 1/2B 1 /B B2_1/
2 3 /4 6 B3 1B/_/2 /1_2 6 B1\n3 3 B10_6 B3 3 /2B_1_6 B1
4 2 2B 1B_B2 B1_B 3 /1B/_/B_B2 B B_B1\n6 1B/11_1/3  B/_/2 3  B/_/"
    IO.puts(ASCII3D.decode(data))

    IO.puts("\n")
  end
end
