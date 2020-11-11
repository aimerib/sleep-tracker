defmodule SleepTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Cluster.Supervisor, [topologies, [name: SleepTracker.ClusterSupervisor]]},
      # Start the Ecto repository
      SleepTracker.Repo,
      # Start the Telemetry supervisor
      SleepTrackerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SleepTracker.PubSub},
      # Start the Endpoint (http/https)
      SleepTrackerWeb.Endpoint
      # Start a worker by calling: SleepTracker.Worker.start_link(arg)
      # {SleepTracker.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SleepTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SleepTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
