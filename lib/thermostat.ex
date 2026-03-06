defmodule Thermostat do
  @moduledoc """
  The Thermostat module starts a Registry for broadcasting updates to the thermostat status, and
  defines the Thermostat struct which represents the current state of the thermostat.

  ## Using the Registry

  ```elixir
  defmodule MyThermostat do
    use GenServer

    def start_link(__opts) do
      GenServer.start_link(__MODULE__, %{thermostat: %Thermostat{}})
    end

    @impl GenServer
    def init(state) do
      {:ok, _} = Thermostat.register()
      {:ok, state}
    end

    @impl GenServer
    def handle_info({:thermostat_target, target} = msg, %{thermostat: thermostat} = state) do
      thermostat = %{thermostat | target: target}
      # Do other work here
      {:noreply, %{state | thermostat: thermostat}}
    end

    def handle_info({:thermostat_target_adjust, target} = msg, %{thermostat: thermostat} = state) do
      thermostat = %{thermostat | target: thermostat.target + target}
      # Do other work here
      {:noreply, %{state | thermostat: thermostat}}
    end

    def handle_info({:thermostat_toggle_mode, mode} = msg, %{thermostat: thermostat} = state) do
      thermostat =
        if thermostat.mode == mode, do: %{thermostat | mode: :off}, else: %{thermostat | mode: mode}

      # Do other work here

      {:noreply, %{state | thermostat: thermostat}}
    end
  end
  ```

  ## Struct fields
  mode: :off | :fan | :heat | :cool | :auto
  equipment_state: :idle | :fan | :heating | :cooling
  started_at:
  target: target heating/cooling temp
  humidity: last humidity polled
  temperature: last temperature polled
  pid: last pid value recorded
  """
  use Supervisor
  require Logger

  @name __MODULE__

  defstruct mode: :off,
            equipment_state: :idle,
            started_at: nil,
            humidity: 0.0,
            target: 15.0,
            temperature: 15.0,
            pid: 0.0

  @type t :: %__MODULE__{
          mode: :off | :fan | :heat | :cool | :auto,
          equipment_state: :idle | :fan | :heating | :cooling,
          started_at: nil | DateTime.t(),
          humidity: float(),
          target: float(),
          temperature: float(),
          pid: float()
        }

  def start_link(opts), do: Supervisor.start_link(@name, opts, name: @name)

  @impl true
  def init(_opts) do
    children = [{Registry, name: registry_name(), keys: :duplicate}]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def child_proc(nil), do: []
  def child_proc(child), do: [child]

  def registry_name, do: Registry.ThermostatPubSub
  def registry_topic, do: "thermostat_update"
  def register(opts \\ []), do: Registry.register(registry_name(), registry_topic(), opts)

  def dispatch(key, event) when is_atom(key) do
    Registry.dispatch(registry_name(), registry_topic(), fn entries ->
      for {pid, _} <- entries, do: send(pid, {key, event})
    end)
  end
end
