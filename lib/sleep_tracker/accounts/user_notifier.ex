defmodule SleepTracker.Accounts.UserNotifier do
  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    email = SleepTrackerWeb.UserEmail.confirm_email(user, url)
    %Swoosh.Email{assigns: %{url: url}} = email

    email
    |> SleepTrackerWeb.Mailer.deliver()
    |> case do
      {:ok, _} -> {:ok, url}
      {_, _} -> {:error, :email_failed_to_deliver}
    end
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    email = SleepTrackerWeb.UserEmail.password_reset(user, url)
    %Swoosh.Email{assigns: %{url: url}} = email

    email
    |> SleepTrackerWeb.Mailer.deliver()
    |> case do
      {:ok, _} -> {:ok, url}
      {_, _} -> {:error, :email_failed_to_deliver}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    email = SleepTrackerWeb.UserEmail.change_email(user, url)
    %Swoosh.Email{assigns: %{url: url}} = email

    email
    |> SleepTrackerWeb.Mailer.deliver()
    |> case do
      {:ok, _} -> {:ok, url}
      {_, _} -> {:error, :email_failed_to_deliver}
    end
  end
end
