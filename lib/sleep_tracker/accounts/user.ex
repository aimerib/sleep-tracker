defmodule SleepTracker.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias SleepTracker.{Metrics, Utils}

  schema "users" do
    field :avatar, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :full_name, :string, virtual: true
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :confirmed_at, :naive_datetime
    field :auth_token, :string
    has_many :readings, Metrics.Reading
    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :auth_token, :avatar, :first_name, :last_name])
    |> validate_email()
    |> validate_password()
    |> validate_required([:first_name, :last_name])
    |> generate_avatar_url()
  end

  def avatar_changeset(user, attrs) do
    user
    |> cast(attrs, [:avatar])
  end

  def first_name_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name])
  end

  def last_name_changeset(user, attrs) do
    user
    |> cast(attrs, [:last_name])
  end

  def auth_token_changeset(user) do
    auth_token = :crypto.strong_rand_bytes(30) |> Base.url_encode64() |> binary_part(0, 30)

    cast(user, %{"auth_token" => auth_token}, [:auth_token])
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, SleepTracker.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 10, max: 80)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> prepare_changes(&hash_password/1)
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    changeset
    |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
    |> delete_change(:password)
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  def reset_auth_token_changeset(user, attrs) do
    user
    |> cast(attrs, [:auth_token])
    |> case do
      %{changes: %{auth_token: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :auth_token, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.
  """
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password()
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%SleepTracker.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  defp generate_avatar_url(changeset) do
    email = get_field(changeset, :email)

    if email == nil do
      changeset
    else
      avatar_url = Utils.get_initial_avatar_url(email)
      put_change(changeset, :avatar, avatar_url)
    end
  end
end
