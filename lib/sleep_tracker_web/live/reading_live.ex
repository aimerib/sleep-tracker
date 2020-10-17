defmodule SleepTrackerWeb.ReadingLive do
  use SleepTrackerWeb, :live_view
  alias SleepTracker.Metrics

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :readings, Metrics.list_readings())
    {:ok, socket}
  end
end
