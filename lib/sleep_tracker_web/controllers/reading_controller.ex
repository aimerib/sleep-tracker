defmodule SleepTrackerWeb.ReadingController do
  use SleepTrackerWeb, :controller

  alias SleepTracker.Metrics
  alias SleepTracker.Metrics.Reading

  def index(conn, params) do
    user_id = conn.assigns.current_user.id
    page = params["page"] || 1
    page_by = params["page_by"] || 25
    readings = Metrics.list_user_readings(:paginated, page, user_id, page_by)
    render(conn, "index.html", readings: readings)
  end

  def new(conn, _params) do
    changeset = Metrics.change_reading(%Reading{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"reading" => reading_params}) do
    user_id = %{"user_id" => conn.assigns.current_user.id}
    reading_params = Enum.into(reading_params, user_id)

    case Metrics.create_reading(reading_params) do
      {:ok, reading} ->
        conn
        |> put_flash(:info, "Reading created successfully.")
        |> redirect(to: Routes.reading_path(conn, :show, reading))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    reading = Metrics.get_reading!(id)
    render(conn, "show.html", reading: reading)
  end

  def edit(conn, %{"id" => id}) do
    reading = Metrics.get_reading!(id)
    changeset = Metrics.change_reading(reading)
    render(conn, "edit.html", reading: reading, changeset: changeset)
  end

  def update(conn, %{"id" => id, "reading" => reading_params}) do
    reading = Metrics.get_reading!(id)

    case Metrics.update_reading(reading, reading_params) do
      {:ok, reading} ->
        conn
        |> put_flash(:info, "Reading updated successfully.")
        |> redirect(to: Routes.reading_path(conn, :show, reading))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", reading: reading, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    reading = Metrics.get_reading!(id)
    {:ok, _reading} = Metrics.delete_reading(reading)

    conn
    |> put_flash(:info, "Reading deleted successfully.")
    |> redirect(to: Routes.reading_path(conn, :index))
  end
end
