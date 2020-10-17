defmodule SleepTrackerWeb.ErrorView do
  use SleepTrackerWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("bad_changeset.json", assigns) do
    %{status: 422, errors: assigns[:errors] |> Enum.map(&parse_errors/1) |> Enum.to_list()}
  end

  def render("reading_not_found.json", _assigns) do
    %{errors: [%{status: "404", title: "Reading Not Found"}]}
  end

  def render("invalid_token.json", _assigns) do
    %{errors: [%{status: "404", title: "Invalid Authorization Token"}]}
  end

  def parse_errors(errors) do
    case errors do
      {field, {error, [type: expected_type, validation: validation_type]}} ->
        %{
          field: field,
          error: error,
          expected_type: expected_type,
          error_type: validation_type
        }

      {field, {error, [validation: validation_type]}} ->
        %{
          field: field,
          error: error,
          error_type: validation_type
        }
    end
  end
end
