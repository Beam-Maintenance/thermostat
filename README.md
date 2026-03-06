# Thermostat

A simple thermostat implementation in Elixir. It consists of a [GenServer](lib/thermostat.ex), [Registry](lib/thermostat.ex), and [LiveView](lib/thermostat_web/live_component.ex).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `thermostat` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:thermostat, github: "Beam-Maintenance/thermostat", tag: "v0.2.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/thermostat>.
