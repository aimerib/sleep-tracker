defmodule SleepTrackerWeb.LandingPageController do
  use SleepTrackerWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end
end
