defmodule SleepTracker.MetricsTest do
  use SleepTracker.DataCase

  alias SleepTracker.Metrics
  import SleepTracker.AccountsFixtures

  describe "readings" do
    alias SleepTracker.Metrics.Reading

    @valid_attrs %{
      bpm: 90,
      deep_sleep_hours: 4,
      deep_sleep_percentage: 90,
      quality_sleep_hours: 5,
      quality_sleep_percentage: 90,
      sleep_hours: 8,
      sleep_percentage: 90,
      sleep_rating: 90
    }
    @update_attrs %{
      bpm: 99,
      deep_sleep_hours: 5,
      deep_sleep_percentage: 99,
      quality_sleep_hours: 6,
      quality_sleep_percentage: 99,
      sleep_hours: 9,
      sleep_percentage: 99,
      sleep_rating: 99
    }
    @invalid_attrs %{
      bpm: nil,
      deep_sleep_hours: nil,
      deep_sleep_percentage: nil,
      quality_sleep_hours: nil,
      quality_sleep_percentage: nil,
      sleep_hours: nil,
      sleep_percentage: nil,
      sleep_rating: nil
    }

    def reading_fixture(attrs \\ %{}) do
      user = user_fixture()

      {:ok, reading} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{user_id: user.id})
        |> Metrics.create_reading()

      reading
      |> SleepTracker.Repo.preload([:user])
    end

    test "list_readings/0 returns all readings" do
      reading = reading_fixture()
      assert Metrics.list_readings() |> SleepTracker.Repo.preload([:user]) == [reading]
    end

    test "get_reading!/1 returns the reading with given id" do
      reading = reading_fixture()
      assert Metrics.get_reading!(reading.id) |> SleepTracker.Repo.preload([:user]) == reading
    end

    test "create_reading/1 with valid data creates a reading" do
      assert {:ok, %Reading{} = reading} = Metrics.create_reading(@valid_attrs)
      assert reading.bpm == 90
      assert reading.deep_sleep_hours == 4
      assert reading.deep_sleep_percentage == 90
      assert reading.quality_sleep_hours == 5
      assert reading.quality_sleep_percentage == 90
      assert reading.sleep_hours == 8
      assert reading.sleep_percentage == 90
      assert reading.sleep_rating == 90
    end

    test "create_reading/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Metrics.create_reading(@invalid_attrs)
    end

    test "update_reading/2 with valid data updates the reading" do
      reading = reading_fixture()
      assert {:ok, %Reading{} = reading} = Metrics.update_reading(reading, @update_attrs)
      assert reading.bpm == 99
      assert reading.deep_sleep_hours == 5
      assert reading.deep_sleep_percentage == 99
      assert reading.quality_sleep_hours == 6
      assert reading.quality_sleep_percentage == 99
      assert reading.sleep_hours == 9
      assert reading.sleep_percentage == 99
      assert reading.sleep_rating == 99
    end

    test "update_reading/2 with invalid data returns error changeset" do
      reading = reading_fixture()
      assert {:error, %Ecto.Changeset{}} = Metrics.update_reading(reading, @invalid_attrs)
      assert reading == Metrics.get_reading!(reading.id) |> SleepTracker.Repo.preload([:user])
    end

    test "delete_reading/1 deletes the reading" do
      reading = reading_fixture()
      assert {:ok, %Reading{}} = Metrics.delete_reading(reading)
      assert_raise Ecto.NoResultsError, fn -> Metrics.get_reading!(reading.id) end
    end

    test "change_reading/1 returns a reading changeset" do
      reading = reading_fixture()
      assert %Ecto.Changeset{} = Metrics.change_reading(reading)
    end
  end
end
