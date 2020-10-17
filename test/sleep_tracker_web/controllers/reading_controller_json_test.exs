defmodule SleepTrackerWeb.ReadingControllerJsonTest do
  use SleepTrackerWeb.ConnCase

  alias SleepTracker.Metrics
  alias SleepTracker.Metrics.Reading

  import SleepTracker.AccountsFixtures

  @create_attrs %{
    bpm: 90,
    deep_sleep_hours: 4.0,
    deep_sleep_percentage: 90,
    quality_sleep_hours: 5.0,
    quality_sleep_percentage: 90,
    sleep_hours: 8.0,
    sleep_percentage: 90,
    sleep_rating: 90
  }
  @update_attrs %{
    bpm: 99,
    deep_sleep_hours: 5.0,
    deep_sleep_percentage: 99,
    quality_sleep_hours: 6.0,
    quality_sleep_percentage: 99,
    sleep_hours: 9.0,
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

  def fixture(:reading) do
    {:ok, reading} = Metrics.create_reading(@create_attrs)
    reading
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user_fixture()}
  end

  describe "index" do
    test "lists all readings", %{conn: conn} do
      conn = get(conn, Routes.reading_json_path(conn, :index))
      assert json_response(conn, 200)["data"]["entries"] == []
    end
  end

  describe "create reading" do
    test "renders reading when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.reading_json_path(conn, :create),
          reading: @create_attrs,
          auth_token: user.auth_token
        )

      %{"id" => id} = json_response(conn, 201)["data"]
      conn = get(conn, Routes.reading_json_path(conn, :show, id))

      assert %{
               "id" => id,
               "bpm" => 90,
               "deep_sleep_hours" => 4.0,
               "deep_sleep_percentage" => 90,
               "quality_sleep_hours" => 5.0,
               "quality_sleep_percentage" => 90,
               "sleep_hours" => 8.0,
               "sleep_percentage" => 90,
               "sleep_rating" => 90
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.reading_json_path(conn, :create),
          reading: @invalid_attrs,
          auth_token: user.auth_token
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update reading" do
    setup [:create_reading]

    test "renders reading when data is valid", %{conn: conn, reading: %Reading{id: id} = reading} do
      conn = put(conn, Routes.reading_json_path(conn, :update, reading), reading: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.reading_json_path(conn, :show, id))

      assert %{
               "id" => id,
               "bpm" => 99,
               "deep_sleep_hours" => 5.0,
               "deep_sleep_percentage" => 99,
               "quality_sleep_hours" => 6.0,
               "quality_sleep_percentage" => 99,
               "sleep_hours" => 9.0,
               "sleep_percentage" => 99,
               "sleep_rating" => 99
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, reading: reading} do
      conn = put(conn, Routes.reading_json_path(conn, :update, reading), reading: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete reading" do
    setup [:create_reading]

    test "deletes chosen reading", %{conn: conn, reading: reading} do
      conn = delete(conn, Routes.reading_json_path(conn, :delete, reading))
      assert response(conn, 204)
      response = get(conn, Routes.reading_json_path(conn, :show, reading))

      expected =
        Jason.encode!(%{"errors" => [%{"status" => "404", "title" => "Reading Not Found"}]})

      assert 404 = response.status
      assert ^expected = response.resp_body
    end
  end

  defp create_reading(_) do
    reading = fixture(:reading)
    %{reading: reading}
  end
end
