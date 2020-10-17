defmodule SleepTracker.Metrics do
  @moduledoc """
  The Metrics context.
  """

  import Ecto.Query, warn: false
  alias SleepTracker.{Repo, Pagination}

  alias SleepTracker.Metrics.Reading

  @doc """
  Returns the list of readings.

  ## Examples

      iex> list_readings()
      [%Reading{}, ...]

  """
  @readings_per_page 25

  def list_readings do
    Repo.all(from r in Reading, preload: [:user])
  end

  def list_readings(a, page \\ 1, per_page \\ @readings_per_page)

  def list_readings(:paginated, page, per_page) do
    Reading
    |> order_by(asc: :id)
    |> Pagination.paginate(%{page: page, preload_attributes: [:user], per_page: per_page})
  end

  def list_user_readings(user_id) do
    case Reading
         |> where([r], r.user_id == ^user_id)
         |> Repo.all() do
      readings when readings != [] -> readings |> Repo.preload(:user)
      _ -> []
    end
  end

  def list_user_readings(a, page \\ 1, user_id, per_page \\ @readings_per_page)

  def list_user_readings(:paginated, page, user_id, per_page) do
    Reading
    |> where([r], r.user_id == ^user_id)
    |> order_by(desc: :inserted_at)
    |> Pagination.paginate(%{page: page, preload_attributes: [:user], per_page: per_page})
  end

  @spec get_reading!(any) :: any
  @doc """
  Gets a single reading.

  Raises `Ecto.NoResultsError` if the Reading does not exist.

  ## Examples

      iex> get_reading!(123)
      %Reading{}

      iex> get_reading!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reading!(id), do: Repo.get!(Reading, id)

  def get_reading(id), do: Repo.get(Reading, id)

  @doc """
  Creates a reading.

  ## Examples

      iex> create_reading(%{field: value})
      {:ok, %Reading{}}

      iex> create_reading(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reading(attrs \\ %{}) do
    %Reading{}
    |> Reading.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reading.

  ## Examples

      iex> update_reading(reading, %{field: new_value})
      {:ok, %Reading{}}

      iex> update_reading(reading, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reading(%Reading{} = reading, attrs) do
    reading
    |> Reading.changeset(attrs)
    |> Repo.update()
  end

  def update_reading(nil, _attrs) do
    {:error, :reading_not_found}
  end

  @doc """
  Deletes a reading.

  ## Examples

      iex> delete_reading(reading)
      {:ok, %Reading{}}

      iex> delete_reading(reading)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reading(%Reading{} = reading) do
    Repo.delete(reading)
  end

  def delete_reading(nil) do
    {:error, :reading_not_found}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reading changes.

  ## Examples

      iex> change_reading(reading)
      %Ecto.Changeset{data: %Reading{}}

  """
  def change_reading(%Reading{} = reading, attrs \\ %{}) do
    Reading.changeset(reading, attrs)
  end
end
