defmodule SleepTracker.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SleepTracker.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def auth_token, do: "sometokeneh?"
  def first_name, do: "John"
  def last_name, do: "Appleseed"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        password: valid_user_password(),
        auth_token: auth_token(),
        first_name: first_name(),
        last_name: last_name()
      })
      |> SleepTracker.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured, "[TOKEN]")
    token
  end
end
