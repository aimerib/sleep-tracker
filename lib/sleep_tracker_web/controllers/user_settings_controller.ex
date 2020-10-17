defmodule SleepTrackerWeb.UserSettingsController do
  use SleepTrackerWeb, :controller

  alias SleepTracker.Accounts
  alias SleepTrackerWeb.UserAuth

  plug :assign_email_and_password_changesets
  plug :assign_auth_token_changeset
  plug :assign_avatar_changeset

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update_avatar(conn, %{"user" => %{"avatar" => avatar_url}}) do
    user = conn.assigns.current_user

    case Accounts.update_avatar(user, avatar_url) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Avatar successfully updated")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", avatar_changeset: changeset)
    end
  end

  def update_email(conn, %{"current_password" => password, "user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  def update_password(conn, %{"current_password" => password, "user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def create_auth_token(conn, _opts) do
    user = conn.assigns.current_user

    case Accounts.create_user_auth_token(user) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Authentication token created")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", auth_token_changeset: changeset)
    end
  end

  def reset_auth_token(conn, _opts) do
    user = conn.assigns.current_user

    case Accounts.reset_auth_token(user) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Authentication token removed")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", auth_token_changeset: changeset)
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end

  defp assign_auth_token_changeset(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:auth_token_changeset, Accounts.create_user_auth_token_changeset(user))
  end

  defp assign_avatar_changeset(conn, opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:avatar_changeset, Accounts.avatar_changeset(user, opts))
  end
end
