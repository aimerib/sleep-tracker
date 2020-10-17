defmodule SleepTracker.Repo.Migrations.CreateReadings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :sleep_percentage, :integer
      add :quality_sleep_percentage, :integer
      add :deep_sleep_percentage, :integer
      add :sleep_hours, :float
      add :quality_sleep_hours, :float
      add :deep_sleep_hours, :float
      add :bpm, :integer
      add :sleep_rating, :integer
      add :sleep_goal, :float
      add :deep_sleep_goal, :float
      add :quality_sleep_goal, :float

      timestamps()
    end
  end
end
