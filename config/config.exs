# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sleep_tracker,
  ecto_repos: [SleepTracker.Repo]

# Configures the endpoint
config :sleep_tracker, SleepTrackerWeb.Endpoint,
  url: [scheme: "http", host: "localhost", port: 4000],
  secret_key_base: "CVzgzfdEhC9mVPvjmh+d6LFs39AGkXkJ/OwngeKfrbCdUt7XQKYPOQJA72N4XHsG",
  render_errors: [view: SleepTrackerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SleepTracker.PubSub,
  live_view: [signing_salt: "CB4Ydtlc"]

config :sleep_tracker, SleepTrackerWeb.Mailer,
  from: "support@sleeptracker.io",
  adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time - [$level] | $metadata $message\n",
  metadata: [:all]

config :logger, :logger_papertrail_backend,
  host: "logs.papertrailapp.com:20103",
  level: :debug,
  system_name: "SleepTracker",
  metadata_filter: [],
  format: " - [$level] | $metadata $message"

config :logger,
  backends: [:console, LoggerPapertrailBackend.Logger],
  level: :debug,
  metadata: [:all]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :honeybadger,
  use_logger: true,
  exclude_envs: [:dev, :test]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
