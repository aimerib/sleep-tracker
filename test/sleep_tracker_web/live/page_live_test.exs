# defmodule SleepTrackerWeb.PageLiveTest do
#   use SleepTrackerWeb.ConnCase

#   import Phoenix.LiveViewTest

#   test "disconnected and connected render", %{conn: conn} do
#     {:ok, page_live, disconnected_html} = live(conn, "/")
#     assert disconnected_html =~ "Welcome to SleepTracker!"
#     assert render(page_live) =~ "Welcome to SleepTracker!"
#   end
# end
