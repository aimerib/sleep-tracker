defmodule SleepTracker.Repo.Migrations.ReadingBelongsToUser do
  use Ecto.Migration

  def change do
    alter table(:readings) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:readings, [:user_id])
  end
end
