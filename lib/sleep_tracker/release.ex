defmodule SleepTracker.Release do
  @app :sleep_tracker

  def create_and_migrate() do
    start_app()
    create_db()
    migrate()
  end

  def create_db do
    load_ssl()

    for repo <- repos() do
      :ok = ensure_repo_created(repo)
    end
  end

  defp ensure_repo_created(repo) do
    IO.puts("create #{inspect(repo)} database if it doesn't exist")

    case repo.__adapter__.storage_up(repo.config) do
      :ok -> :ok
      {:error, :already_up} -> :ok
      {:error, term} -> {:error, term}
    end
  end

  def migrate do
    load_ssl()
    IO.puts("Running migrations for app")

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    IO.puts("Finished running migrations for app")
  end

  def rollback(repo, version) do
    load_ssl()
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp load_ssl do
    Application.ensure_all_started(:ssl)
  end

  defp start_app do
    load_app()
  end
end
