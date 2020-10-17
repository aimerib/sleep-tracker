defmodule SleepTrackerWeb.ReadingJsonView do
  use SleepTrackerWeb, :view
  alias SleepTrackerWeb.ReadingJsonView

  def render("index.json", %{readings: readings}) do
    %{data: render_many(readings, ReadingJsonView, "reading.json")}
  end

  def render("show.json", %{reading: reading}) do
    %{data: render_one(reading, ReadingJsonView, "reading.json")}
  end

  def render("reading.json", %{reading_json: reading}) do
    %{
      id: reading.id,
      sleep_percentage: reading.sleep_percentage,
      quality_sleep_percentage: reading.quality_sleep_percentage,
      deep_sleep_percentage: reading.deep_sleep_percentage,
      sleep_hours: reading.sleep_hours,
      quality_sleep_hours: reading.quality_sleep_hours,
      deep_sleep_hours: reading.deep_sleep_hours,
      bpm: reading.bpm,
      sleep_rating: reading.sleep_rating,
      sleep_goal: reading.sleep_goal,
      deep_sleep_goal: reading.deep_sleep_goal,
      quality_sleep_goal: reading.quality_sleep_goal
    }
  end
end
