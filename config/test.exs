use Mix.Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sleep_tracker, SleepTracker.Repo,
  username: "postgres",
  password: "postgres",
  database: "sleep_tracker_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sleep_tracker, SleepTrackerWeb.Endpoint,
  http: [port: 4002],
  url: [scheme: "http", host: "localhost", port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, :console, level: :warn

config :sleep_tracker, SleepTrackerWeb.Mailer, adapter: Swoosh.Adapters.Test
