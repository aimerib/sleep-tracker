defmodule SleepTrackerWeb.ReadingJsonController do
  use SleepTrackerWeb, :controller

  alias SleepTracker.Accounts
  alias SleepTracker.Accounts.User
  alias SleepTracker.Metrics
  alias SleepTracker.Metrics.Reading
  alias SleepTracker.Utils

  action_fallback SleepTrackerWeb.FallbackController

  def index(conn, params) do
    page = params["page"] || 1
    per_page = params["per_page"] || 100
    readings = Metrics.list_readings(:paginated, page, per_page)
    json(conn, %{data: readings})
  end

  def create(conn, %{"reading" => reading_params, "auth_token" => user_auth_token}) do
    case Accounts.get_user_by_auth_token(user_auth_token) do
      %User{} = user ->
        reading_params =
          reading_params
          |> Enum.into(%{user_id: user.id})
          |> Enum.map(&rename_param_keys/1)
          |> Enum.into(%{})
          |> Utils.strong_params([
            :deep_sleep_hours,
            :deep_sleep_percentage,
            :quality_sleep_hours,
            :quality_sleep_percentage,
            :sleep_hours,
            :sleep_percentage,
            :sleep_rating,
            :bpm,
            :user_id
          ])
          |> key_to_atom()

        case Metrics.create_reading(reading_params) do
          {:ok, %Reading{} = reading} -> conn |> put_status(:created) |> json(%{data: reading})
          {:error, %Ecto.Changeset{errors: errors}} -> {:error, :invalid_changeset, errors}
        end

      nil ->
        {:error, :invalid_token}
    end
  end

  def show(conn, %{"id" => id}) do
    case Metrics.get_reading(id) do
      %Reading{} = reading -> json(conn, %{data: reading})
      nil -> {:error, :reading_not_found}
    end
  end

  def update(conn, %{"id" => id, "reading" => reading_params}) do
    reading = Metrics.get_reading(id)

    case Metrics.update_reading(reading, reading_params) do
      {:error, %Ecto.Changeset{errors: errors}} -> {:error, :invalid_changeset, errors}
      {:error, :reading_not_found} -> {:error, :reading_not_found}
      {:ok, %Reading{} = reading} -> json(conn, %{data: reading})
    end
  end

  def delete(conn, %{"id" => id}) do
    reading = Metrics.get_reading!(id)

    case Metrics.delete_reading(reading) do
      {:ok, %Reading{}} -> send_resp(conn, :no_content, "")
      {:error, :reading_not_found} -> {:error, :reading_not_found}
    end
  end

  defp rename_param_keys({key, value}) do
    case key do
      "Deep" ->
        {"deep_sleep_hours", value}

      "Deep%" ->
        {"deep_sleep_percentage", value}

      "Quality" ->
        {"quality_sleep_hours", value}

      "Quality%" ->
        {"quality_sleep_percentage", value}

      "Sleep" ->
        {"sleep_hours", value}

      "Sleep%" ->
        {"sleep_percentage", value}

      "SleepRating" ->
        {"sleep_rating", value}

      "bpm" ->
        {"bpm", value}

      _ ->
        {key, value}
    end
  end

  defp key_to_atom(map) do
    Enum.reduce(map, %{}, fn
      # String.to_existing_atom saves us from overloading the VM by
      # creating too many atoms. It'll always succeed because all the fields
      # in the database already exist as atoms at runtime.
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_existing_atom(key), value)
    end)
  end
end
