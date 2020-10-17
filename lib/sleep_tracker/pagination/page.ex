defmodule SleepTracker.Pagination.Page do
  @moduledoc """
  A `SleepTracker.Pagination.Page` has 11 fields that can be accessed: `page_number`, `page_size`, `total_entries`, `total_pages`, `has_next`, `has_previous`, `previous_page`, `next_page`, `first_entry`, `last_entry`, and `entries`.
      page = MyApp.Module.paginate(params)
      page.page_number
      page.page_size
      page.total_entries
      page.total_pages
      page.has_next
      page.has_previous
      page.previous_page
      page.next_page
      page.first_entry
      page.last_entry
      page.entries
  """
  @derive {Jason.Encoder,
           only: [
             :page_number,
             :page_size,
             :total_entries,
             :total_pages,
             :has_next,
             :has_previous,
             :previous_page,
             :next_page,
             :first_entry,
             :last_entry,
             :entries
           ]}

  defstruct [
    :page_number,
    :page_size,
    :total_entries,
    :total_pages,
    :has_next,
    :has_previous,
    :previous_page,
    :next_page,
    :first_entry,
    :last_entry,
    entries: []
  ]

  @type t :: %__MODULE__{
          has_next: boolean(),
          has_previous: boolean(),
          previous_page: pos_integer(),
          page_number: integer(),
          next_page: pos_integer(),
          page_size: integer(),
          first_entry: integer(),
          last_entry: integer(),
          total_entries: integer(),
          total_pages: integer(),
          entries: list()
        }

  defimpl Enumerable do
    @spec count(SleepTracker.Pagination.Page.t()) ::
            {:error, Enumerable.SleepTracker.Pagination.Page}
    def count(_page), do: {:error, __MODULE__}

    @spec member?(SleepTracker.Pagination.Page.t(), term) ::
            {:error, Enumerable.SleepTracker.Pagination.Page}
    def member?(_page, _value), do: {:error, __MODULE__}

    @spec reduce(SleepTracker.Pagination.Page.t(), Enumerable.acc(), Enumerable.reducer()) ::
            Enumerable.result()
    def reduce(%SleepTracker.Pagination.Page{entries: entries}, acc, fun) do
      Enumerable.reduce(entries, acc, fun)
    end

    @spec slice(SleepTracker.Pagination.Page.t()) ::
            {:error, Enumerable.SleepTracker.Pagination.Page}
    def slice(_page), do: {:error, __MODULE__}
  end

  defimpl Collectable do
    @spec into(SleepTracker.Pagination.Page.t()) ::
            {term, (term, Collectable.command() -> SleepTracker.Pagination.Page.t() | term)}
    def into(original) do
      original_entries = original.entries
      impl = Collectable.impl_for(original_entries)
      {_, entries_fun} = impl.into(original_entries)

      fun = fn page, command ->
        %{page | entries: entries_fun.(page.entries, command)}
      end

      {original, fun}
    end
  end
end
