defmodule SleepTracker.Repo do
  use Ecto.Repo,
    otp_app: :sleep_tracker,
    adapter: Ecto.Adapters.Postgres
end
