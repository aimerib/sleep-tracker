defmodule SleepTrackerWeb.UserEmail do
  use Phoenix.Swoosh,
    view: SleepTrackerWeb.EmailView,
    layout: {SleepTrackerWeb.EmailLayoutView, :email}

  def confirm_email(user, url) do
    prepare(user)
    |> subject("Please confirm the email for your SleepTracker account")
    |> render_body("confirmation.html", %{user: user, url: url})
  end

  def password_reset(user, url) do
    prepare(user)
    |> subject("Password reset request")
    |> render_body("password_reset.html", %{user: user, url: url})
  end

  def change_email(user, url) do
    prepare(user)
    |> subject("Email change request")
    |> render_body("change_email.html", %{user: user, url: url})
  end

  defp prepare(user) do
    new()
    |> to(user.email)
    |> from({
      "SleepTracker",
      Application.get_env(:sleep_tracker, SleepTrackerWeb.Mailer)[:from]
    })
    |> assign(:app_uri, SleepTrackerWeb.Endpoint.url())
  end
end
