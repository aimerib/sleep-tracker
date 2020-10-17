defmodule SleepTrackerWeb.ReadingControllerTest do
  use SleepTrackerWeb.ConnCase

  alias SleepTracker.Metrics
  import SleepTracker.AccountsFixtures

  @create_attrs %{
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

  setup do
    %{user: user_fixture()}
  end

  def fixture(:reading) do
    {:ok, reading} = Metrics.create_reading(@create_attrs)
    reading
  end

  describe "index" do
    test "lists all readings", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.reading_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Readings"
    end
  end

  describe "new reading" do
    test "renders form", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.reading_path(conn, :new))
      assert html_response(conn, 200) =~ "New Reading"
    end
  end

  describe "create reading" do
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.reading_path(conn, :create), reading: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.reading_path(conn, :show, id)

      conn = get(conn, Routes.reading_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Reading"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.reading_path(conn, :create), reading: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Reading"
    end
  end

  describe "edit reading" do
    setup [:create_reading]

    test "renders form for editing chosen reading", %{conn: conn, reading: reading, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.reading_path(conn, :edit, reading))
      assert html_response(conn, 200) =~ "Edit Reading"
    end
  end

  describe "update reading" do
    setup [:create_reading]

    test "redirects when data is valid", %{conn: conn, reading: reading, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> put(Routes.reading_path(conn, :update, reading), reading: @update_attrs)

      assert redirected_to(conn) == Routes.reading_path(conn, :show, reading)

      conn = get(conn, Routes.reading_path(conn, :show, reading))
      assert html_response(conn, 200) =~ "99"
    end

    test "renders errors when data is invalid", %{conn: conn, reading: reading, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> put(Routes.reading_path(conn, :update, reading), reading: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Reading"
    end
  end

  describe "delete reading" do
    setup [:create_reading]

    test "deletes chosen reading", %{conn: conn, reading: reading, user: user} do
      conn = conn |> log_in_user(user) |> delete(Routes.reading_path(conn, :delete, reading))
      assert redirected_to(conn) == Routes.reading_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.reading_path(conn, :show, reading))
      end
    end
  end

  defp create_reading(_) do
    reading = fixture(:reading)
    %{reading: reading}
  end
end
