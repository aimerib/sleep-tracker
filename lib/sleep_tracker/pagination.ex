defmodule SleepTracker.Pagination do
  import Ecto.Query
  alias SleepTracker.Repo
  alias SleepTracker.Pagination.Page

  def entries(query, page, preload_attributes, per_page) when is_binary(page) do
    entries(query, String.to_integer(page), preload_attributes, per_page)
  end

  def entries(query, page, preload_attributes, per_page) when is_binary(per_page) do
    entries(query, page, preload_attributes, String.to_integer(per_page))
  end

  def entries(query, page, preload_attributes, per_page) do
    query
    |> limit(^per_page)
    |> offset(^(per_page * (page - 1)))
    |> Repo.all()
    |> Repo.preload(preload_attributes)
  end

  def paginate(query, options \\ %{})

  def paginate(
        query,
        %{page: page, per_page: per_page, preload_attributes: preload_attributes}
      )
      when is_binary(page) do
    defaults = %{preload_attributes: []}

    options =
      Map.merge(defaults, %{
        page: String.to_integer(page),
        per_page: per_page,
        preload_attributes: preload_attributes
      })
      |> Enum.into(%{})

    paginate(
      query,
      options
    )
  end

  def paginate(query, %{page: page, per_page: per_page, preload_attributes: preload_attributes})
      when is_binary(per_page) do
    defaults = %{preload_attributes: []}

    options =
      Map.merge(defaults, %{
        page: page,
        per_page: String.to_integer(per_page),
        preload_attributes: preload_attributes
      })
      |> Enum.into(%{})

    paginate(
      query,
      options
    )
  end

  def paginate(query, options) do
    defaults = %{preload_attributes: []}
    options = Map.merge(defaults, options) |> Enum.into(%{})
    %{page: page, preload_attributes: preload_attributes, per_page: per_page} = options

    results = entries(query, page, preload_attributes, per_page)
    has_next = length(results) > per_page
    has_prev = page > 1
    count = Repo.one(from(t in subquery(query), select: count("*")))

    %Page{
      has_next: has_next,
      has_previous: has_prev,
      previous_page: page - 1,
      page_number: page,
      next_page: page + 1,
      page_size: per_page,
      first_entry: (page - 1) * per_page + 1,
      last_entry: Enum.min([page * per_page, count]),
      total_entries: count,
      entries: Enum.slice(results, 0, per_page),
      total_pages: (count / per_page) |> ceil()
    }
  end
end
