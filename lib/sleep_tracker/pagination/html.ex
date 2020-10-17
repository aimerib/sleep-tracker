defmodule SleepTracker.Pagination.HTML do
  use Phoenix.HTML
  @defaults [action: :index, page_param: :page, hide_single: false]
  @raw_defaults [
    distance: 1,
    next: "Next ☞",
    previous: "☜ Previous",
    first: true,
    last: true,
    ellipsis: raw("&hellip;")
  ]

  @doc false
  defmacro __using__(_) do
    quote do
      import SleepTracker.Pagination.HTML
      import SleepTracker.Pagination.HTML.SEO
    end
  end

  defmodule Default do
    def path(_conn, _action, opts \\ []) do
      "?" <> Plug.Conn.Query.encode(opts)
    end
  end

  def pagination_links(conn, paginator, args, opts) do
    opts =
      Keyword.merge(opts,
        hide_single:
          opts[:hide_single] ||
            Application.get_env(:sleeptracker_pagination_html, :hide_single, false)
      )

    merged_opts = Keyword.merge(@defaults, opts)

    path = opts[:path] || find_path_fn(conn && paginator.entries, args)
    params = Keyword.drop(opts, Keyword.keys(@defaults) ++ [:path, :hide_single])
    next = opts[:next] || @raw_defaults[:next]
    previous = opts[:previous] || @raw_defaults[:previous]
    hide_single_result = opts[:hide_single] && paginator.total_pages < 2

    if hide_single_result do
      Phoenix.HTML.raw(nil)
    else
      _pagination_links(paginator,
        path: path,
        args: [conn, merged_opts[:action]] ++ args,
        page_param: merged_opts[:page_param],
        params: params,
        next: next,
        previous: previous
      )
    end
  end

  def pagination_links(%SleepTracker.Pagination.Page{} = paginator),
    do: pagination_links(nil, paginator, [], [])

  def pagination_links(%SleepTracker.Pagination.Page{} = paginator, opts),
    do: pagination_links(nil, paginator, [], opts)

  def pagination_links(conn, %SleepTracker.Pagination.Page{} = paginator),
    do: pagination_links(conn, paginator, [], [])

  def pagination_links(conn, paginator, [{_, _} | _] = opts),
    do: pagination_links(conn, paginator, [], opts)

  def pagination_links(conn, paginator, [_ | _] = args),
    do: pagination_links(conn, paginator, args, [])

  def find_path_fn(nil, _path_args), do: &Default.path/3
  def find_path_fn([], _path_args), do: fn _, _, _ -> nil end

  if Code.ensure_loaded(Phoenix.Naming) do
    def find_path_fn(entries, path_args) do
      routes_helper_module =
        Application.get_env(:sleeptracker_pagination_html, :routes_helper) ||
          raise(
            "SleepTracker.Pagination.HTML: Unable to find configured routes_helper module (ex. MyApp.Router.Helper)"
          )

      path = path_args |> Enum.reduce(name_for(List.first(entries), ""), &name_for/2)

      {path_fn, []} =
        Code.eval_quoted(
          quote do:
                  &(unquote(routes_helper_module).unquote(:"#{path <> "_path"}") /
                      unquote(length(path_args) + 3))
        )

      path_fn
    end
  else
    def find_path_fn(_entries, _args), do: &(Default / 3)
  end

  defp name_for(model, acc) do
    "#{acc}#{if(acc != "", do: "_")}#{Phoenix.Naming.resource_name(model.__struct__)}"
  end

  defp _pagination_links(paginator,
         path: path,
         args: args,
         page_param: page_param,
         params: params,
         next: next,
         previous: previous
       ) do
    url_params = Keyword.drop(params, Keyword.keys(@raw_defaults))

    content_tag :nav, class: "pagination is-centered" do
      content_tag :ul, class: "pagination-list" do
        raw_pagination_links(paginator, params)
        |> Enum.map(&page(&1, url_params, args, page_param, path, paginator, next, previous))
      end
    end
  end

  defp page({:ellipsis, true}, url_params, args, page_param, path, paginator, next, previous) do
    page(
      {:ellipsis, unquote(@raw_defaults[:ellipsis])},
      url_params,
      args,
      page_param,
      path,
      paginator,
      next,
      previous
    )
  end

  defp page(
         {:ellipsis, text},
         _url_params,
         _args,
         _page_param,
         _path,
         paginator,
         _next,
         _previous
       ) do
    content_tag(:li, class: li_classes(paginator, :ellipsis) |> Enum.join(" ")) do
      ellipsis_tag()
      |> content_tag(safe(text),
        class: link_classes(paginator, :ellipsis) |> Enum.join(" ")
      )
    end
  end

  defp page({text, page_number}, url_params, args, page_param, path, paginator, next, previous) do
    params_with_page =
      url_params ++
        case page_number > 1 do
          true -> [{page_param, page_number}]
          false -> []
        end

    content_tag :li, class: li_classes(paginator, page_number) |> Enum.join(" ") do
      to = apply(path, args ++ [params_with_page])

      if to do
        if active_page?(paginator, page_number) do
          content_tag(:a, safe(text),
            class: link_classes(paginator, page_number) |> Enum.join(" ")
          )
        else
          cond do
            text == previous ->
              cond do
                page_number < 1 ->
                  link(safe(text),
                    to: to,
                    rel: SleepTracker.Pagination.HTML.SEO.rel(paginator, page_number),
                    class:
                      link_classes(paginator, page_number, :previous, :disabled) |> Enum.join(" ")
                  )

                true ->
                  link(safe(text),
                    to: to,
                    rel: SleepTracker.Pagination.HTML.SEO.rel(paginator, page_number),
                    class:
                      link_classes(paginator, page_number, :previous, :enabled) |> Enum.join(" ")
                  )
              end

            text == next ->
              cond do
                paginator.total_pages == page_number - 1 ->
                  link(safe(text),
                    to: to,
                    rel: SleepTracker.Pagination.HTML.SEO.rel(paginator, page_number),
                    class:
                      link_classes(paginator, page_number, :next, :disabled) |> Enum.join(" ")
                  )

                paginator.total_pages >= page_number - 1 ->
                  link(safe(text),
                    to: to,
                    rel: SleepTracker.Pagination.HTML.SEO.rel(paginator, page_number),
                    class: link_classes(paginator, page_number, :next, :enabled) |> Enum.join(" ")
                  )
              end

            true ->
              link(safe(text),
                to: to,
                rel: SleepTracker.Pagination.HTML.SEO.rel(paginator, page_number),
                class: link_classes(paginator, page_number) |> Enum.join(" ")
              )
          end
        end
      else
        blank_link_tag()
        |> content_tag(safe(text),
          class: link_classes(paginator, page_number) |> Enum.join(" ")
        )
      end
    end
  end

  defp active_page?(%{page_number: page_number}, page_number), do: true
  defp active_page?(_paginator, _page_number), do: false

  defp li_classes(_paginator, :ellipsis), do: []
  defp li_classes(_paginator, _page_number), do: []

  defp link_classes(_paginator, :ellipsis), do: ["pagination-ellipsis"]

  defp link_classes(paginator, page_number) do
    if(paginator.page_number == page_number,
      do: ["pagination-link", "is-current"],
      else: ["pagination-link"]
    )
  end

  defp link_classes(_paginator, _page_number, :next, :disabled) do
    ["pagination-link", "pagination-next", "pagination-previous-next-disabled"]
  end

  defp link_classes(_paginator, _page_number, :next, _enabled_disabled) do
    ["pagination-link", "pagination-next"]
  end

  defp link_classes(_paginator, _page_number, :previous, :disabled) do
    ["pagination-link", "pagination-previous", "pagination-previous-next-disabled"]
  end

  defp link_classes(_paginator, _page_number, :previous, _enabled_disabled) do
    ["pagination-link", "pagination-previous"]
  end

  defp ellipsis_tag(), do: :span
  defp blank_link_tag(), do: :a

  def raw_pagination_links(paginator, options \\ []) do
    options = Keyword.merge(@raw_defaults, options)

    add_first(paginator.page_number, options[:distance], options[:first])
    |> add_first_ellipsis(
      paginator.page_number,
      paginator.total_pages,
      options[:distance],
      options[:first]
    )
    |> add_previous(paginator.page_number)
    |> page_number_list(paginator.page_number, paginator.total_pages, options[:distance])
    |> add_last_ellipsis(
      paginator.page_number,
      paginator.total_pages,
      options[:distance],
      options[:last]
    )
    |> add_last(paginator.page_number, paginator.total_pages, options[:distance], options[:last])
    |> add_next(paginator.page_number, paginator.total_pages)
    |> Enum.map(fn
      :next ->
        if options[:next], do: {options[:next], paginator.page_number + 1}

      :previous ->
        if options[:previous], do: {options[:previous], paginator.page_number - 1}

      :first_ellipsis ->
        if options[:ellipsis] && options[:first], do: {:ellipsis, options[:ellipsis]}

      :last_ellipsis ->
        if options[:ellipsis] && options[:last], do: {:ellipsis, options[:ellipsis]}

      :first ->
        if options[:first], do: {options[:first], 1}

      :last ->
        if options[:last], do: {options[:last], paginator.total_pages}

      num when is_number(num) ->
        {num, num}
    end)
    |> Enum.filter(& &1)
  end

  defp page_number_list(list, page, total, distance)
       when is_integer(distance) and distance >= 1 do
    list ++
      Enum.to_list(beginning_distance(page, total, distance)..end_distance(page, total, distance))
  end

  defp page_number_list(_list, _page, _total, _distance) do
    raise "SleepTracker.Pagination.HTML: Distance cannot be less than one."
  end

  defp beginning_distance(page, _total, distance) when page - distance < 1 do
    page - (distance + (page - distance - 1))
  end

  defp beginning_distance(page, _total, distance) when page - distance < 3 do
    page - distance
  end

  defp beginning_distance(page, total, distance) when page < total and total - page == 1 do
    page - distance
  end

  defp beginning_distance(page, total, distance) when page < total do
    page - distance + 1
  end

  defp beginning_distance(page, total, _distance) when page == total do
    total - 2
  end

  defp beginning_distance(page, total, distance) when page > total do
    total - distance
  end

  defp end_distance(page, total, distance) when page + distance >= total and total != 0 do
    total
  end

  defp end_distance(_page, 0, _distance) do
    1
  end

  defp end_distance(page, total, distance)
       when page == 1 and total < 4 do
    page + distance
  end

  defp end_distance(page, _total, distance)
       when page == 1 do
    page + distance + 1
  end

  defp end_distance(page, total, distance) when page + distance < total and total - page <= 2 do
    page + distance
  end

  defp end_distance(page, total, distance)
       when page + distance < total and page - distance <= 1 do
    page + distance
  end

  defp end_distance(page, total, distance) when page + distance < total do
    page
  end

  defp add_previous(list, _page) do
    [:previous | list]
  end

  defp add_first(page, distance, true) when page - distance > 1 do
    [1]
  end

  defp add_first(page, distance, first) when page - distance > 1 and first != false do
    [:first]
  end

  defp add_first(_page, _distance, _included) do
    []
  end

  defp add_last(list, page, total, distance, true) when page + distance < total do
    list ++ [total]
  end

  defp add_last(list, page, total, distance, last)
       when page + distance < total and last != false do
    list ++ [:last]
  end

  defp add_last(list, _page, _total, _distance, _included) do
    list
  end

  defp add_next(list, _page, _total) do
    list ++ [:next]
  end

  defp add_first_ellipsis(list, page, total, distance, true) do
    add_first_ellipsis(list, page, total, distance + 1, nil)
  end

  defp add_first_ellipsis(list, page, total, distance, _first)
       when page - distance > 1 and total < 5 do
    list
  end

  defp add_first_ellipsis(list, page, _total, distance, _first)
       when page - distance > 1 and page > 3 do
    list ++ [:first_ellipsis]
  end

  defp add_first_ellipsis(list, _page_number, _total, _distance, _first) do
    list
  end

  defp add_last_ellipsis(list, page, total, distance, true) do
    add_last_ellipsis(list, page, total, distance + 1, nil)
  end

  defp add_last_ellipsis(list, page, total, distance, _)
       when page + distance < total and page != total and total < 5 do
    list
  end

  defp add_last_ellipsis(list, page, total, distance, _)
       when page + distance < total and page != total do
    list ++ [:last_ellipsis]
  end

  defp add_last_ellipsis(list, _page_number, _total, _distance, _last) do
    list
  end

  defp safe({:safe, _string} = whole_string) do
    whole_string
  end

  defp safe(string) when is_binary(string) do
    string
  end

  defp safe(string) do
    string
    |> to_string()
    |> raw()
  end

  def defaults(), do: @defaults
end
