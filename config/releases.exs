import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :sleep_tracker, SleepTracker.Repo,
  url: database_url,
  ssl: true,
  # ssl_opts: [cacertfile: '/app/certs/ca-certificate.crt'],
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :sleep_tracker, SleepTrackerWeb.Mailer,
  from: "support@mail.sleeptracker.io",
  adapter: Swoosh.Adapters.SparkPost,
  api_key: System.get_env("SPARKPOST_API"),
  endpoint: "https://api.sparkpost.com/api/v1"

# application_port = System.get_env("APP_PORT") || "4000"

config :sleep_tracker, SleepTrackerWeb.Endpoint,
  http: [port: 4000],
  url: [scheme: "https", host: "www.sleeptracker.io", port: 443],
  secret_key_base: secret_key_base
