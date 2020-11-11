use Mix.Config

config :sleep_tracker, SleepTrackerWeb.Endpoint,
  server: true,
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

# Do not print debug messages in production
config :logger, level: :info

# database_url =
#   System.get_env("DATABASE_URL") ||
#     raise """
#     environment variable DATABASE_URL is missing.
#     For example: ecto://USER:PASS@HOST/DATABASE
#     """

# config :sleep_tracker, SleepTracker.Repo,
#   url: database_url,
#   ssl: true,
#   # ssl_opts: [cacertfile: '/app/certs/ca-certificate.crt'],
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "2")

# secret_key_base =
#   System.get_env("SECRET_KEY_BASE") ||
#     raise """
#     environment variable SECRET_KEY_BASE is missing.
#     You can generate one by calling: mix phx.gen.secret
#     """

# config :sleep_tracker, SleepTrackerWeb.Mailer,
#   from: "support@mail.sleeptracker.io",
#   adapter: Swoosh.Adapters.SparkPost,
#   api_key: System.get_env("SPARKPOST_API"),
#   endpoint: "https://api.sparkpost.com/api/v1"

# # application_port = System.get_env("APP_PORT") || "4000"

# config :sleep_tracker, SleepTrackerWeb.Endpoint,
#   http: [port: 4000],
#   url: [scheme: "https", host: "www.sleeptracker.io", port: 443],
#   secret_key_base: secret_key_base,
#   force_ssl: [rewrite_on: [:x_forwarded_proto]]

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :sleep_tracker, SleepTrackerWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#         transport_options: [socket_opts: [:inet6]]
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :sleep_tracker, SleepTrackerWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.
