defmodule SleepTrackerWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use SleepTrackerWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(SleepTrackerWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :invalid_changeset, errors}) do
    conn
    |> put_status(422)
    |> put_view(SleepTrackerWeb.ErrorView)
    |> render(:bad_changeset, errors: errors)
  end

  def call(conn, {:error, :reading_not_found}) do
    conn
    |> put_status(404)
    |> put_view(SleepTrackerWeb.ErrorView)
    |> render(:reading_not_found)
  end

  def call(conn, {:error, :invalid_token}) do
    conn
    |> put_status(404)
    |> put_view(SleepTrackerWeb.ErrorView)
    |> render(:invalid_token)
  end
end
