defmodule SleepTracker.Metrics.Reading do
  use Ecto.Schema
  import Ecto.Changeset
  alias SleepTracker.Accounts

  @derive {Jason.Encoder,
           only: [
             :id,
             :bpm,
             :deep_sleep_hours,
             :deep_sleep_percentage,
             :quality_sleep_hours,
             :quality_sleep_percentage,
             :sleep_hours,
             :sleep_percentage,
             :sleep_rating,
             :sleep_goal,
             :deep_sleep_goal,
             :quality_sleep_goal,
             :user_id
           ]}

  schema "readings" do
    field :bpm, :integer
    field :deep_sleep_hours, :float
    field :deep_sleep_percentage, :integer
    field :quality_sleep_hours, :float
    field :quality_sleep_percentage, :integer
    field :sleep_hours, :float
    field :sleep_percentage, :integer
    field :sleep_rating, :integer
    field :sleep_goal, :float
    field :deep_sleep_goal, :float
    field :quality_sleep_goal, :float
    belongs_to :user, Accounts.User
    timestamps()
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [
      :sleep_percentage,
      :quality_sleep_percentage,
      :deep_sleep_percentage,
      :sleep_hours,
      :quality_sleep_hours,
      :deep_sleep_hours,
      :bpm,
      :sleep_rating,
      :user_id
    ])
    |> calculate_sleep_goal()
    |> calculate_deep_sleep_goal()
    |> calculate_quality_sleep_goal()
    |> validate_required([
      :sleep_percentage,
      :quality_sleep_percentage,
      :deep_sleep_percentage,
      :sleep_hours,
      :quality_sleep_hours,
      :deep_sleep_hours,
      :bpm,
      :sleep_rating,
      :sleep_goal,
      :deep_sleep_goal,
      :quality_sleep_goal
    ])
  end

  defp calculate_sleep_goal(changeset) do
    sleep_goal =
      try do
        (get_field(changeset, :sleep_hours) /
           get_field(changeset, :sleep_percentage) * 100)
        |> Decimal.from_float()
        |> Decimal.round(1)
        |> Decimal.to_float()
      rescue
        ArithmeticError -> 0.0
      end

    put_change(changeset, :sleep_goal, sleep_goal)
  end

  defp calculate_deep_sleep_goal(changeset) do
    deep_sleep_goal =
      try do
        (get_field(changeset, :deep_sleep_hours) /
           get_field(changeset, :deep_sleep_percentage) *
           100)
        |> Decimal.from_float()
        |> Decimal.round(1)
        |> Decimal.to_float()
      rescue
        ArithmeticError -> 0.0
      end

    put_change(changeset, :deep_sleep_goal, deep_sleep_goal)
  end

  defp calculate_quality_sleep_goal(changeset) do
    quality_sleep_goal =
      try do
        (get_field(changeset, :quality_sleep_hours) /
           get_field(changeset, :quality_sleep_percentage) * 100)
        |> Decimal.from_float()
        |> Decimal.round(1)
        |> Decimal.to_float()
      rescue
        ArithmeticError -> 0.0
      end

    put_change(changeset, :quality_sleep_goal, quality_sleep_goal)
  end
end
