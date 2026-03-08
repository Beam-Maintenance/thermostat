defmodule ThermostatWeb.StatusHandler do
  use Phoenix.Component
  require Logger
  import Phoenix.LiveView

  def on_mount(_, _params, _session, socket) do
    Logger.debug("Mounting ThermostatWeb.StatusHandler, attaching hooks")
    {:ok, _} = Thermostat.register()

    socket =
      socket
      |> assign_new(:thermostat, fn _ -> %Thermostat{} end)
      |> assign_show_heater_cooler()
      |> attach_hook(:status_handle_info, :handle_info, &hooked_info/2)

    {:cont, socket}
  end

  def hooked_info({:thermostat_status, %Thermostat{} = thermostat}, socket) do
    Logger.debug("Received thermostat status update #{inspect(thermostat)}")
    {:cont, socket |> assign(thermostat: thermostat) |> assign_show_heater_cooler()}
  end

  def hooked_info(_msg, socket) do
    {:cont, socket}
  end

  def assign_show_heater_cooler(%{assigns: %{thermostat: thermostat}} = socket) do
    {show_heater, show_cooler} =
      cond do
        thermostat.mode == :heat -> {true, false}
        thermostat.mode == :cool -> {false, true}
        true -> {true, true}
      end

    socket
    |> assign(:show_heater, show_heater)
    |> assign(:show_cooler, show_cooler)
  end
end
