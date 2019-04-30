# ChatApp

Features

 - Ranch for socket acceptor
 - Client and Server supervisors
 - Ability to join a room
 - Ability to change your nickname

## Running the app

Build the CLI with 

```
mix escript.build
```

Run the server with

```
./chat_app --server
```

Connect with the client. Default server port is listening to is 4000

```
./chat_app --client
```

Or with telnet

```
telnet 0.0.0.0 4000
```

## Commands

Change your nickname
```
/nick Neo
```

Join a channel
```
/join #weedmaps
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `chat_app` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chat_app, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/chat_app](https://hexdocs.pm/chat_app).

