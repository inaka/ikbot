defmodule Ikbot.Script.News do
  alias HTTPotion.Response
  def base(_message) do
    get_news("")
  end
  
  def about(%{body: q}) do
    get_news(URI.encode(q))
  end
  
  def get_news(q) do
    url = "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q=https://news.google.com/news/feeds?q=#{q}"
    case HTTPotion.get(url, [], []) do
      %Response{body: body, status_code: 200} ->
        body
        |> get_entries
        |> parse_entries
      %Response{status_code: status_code} ->
        "Sorry. Something went wrong (code: #{status_code})"
    end
  end
  
  defp get_entries(body) do
    parsed_body = parse_body(body)
    
    :proplists.get_value("entries",
      :proplists.get_value("feed",
        :proplists.get_value(:responseData, parsed_body)
      )
    )
  end

  defp parse_entries(entries) do
    :random.seed(:os.timestamp)
    Enum.join(
      Enum.map(
        Enum.take(Enum.shuffle(entries), 2), 
        &parse_entry/1
      ),
      "\n\n"
    )
  end

  defp parse_entry(entry) do
    title = :proplists.get_value("title", entry)
    url = get_url(entry)

    Enum.join([title, url], "\n")
  end

  defp get_url(entry) do
    link = :proplists.get_value("link", entry)
    {:ok, regex} = Regex.compile("&url=.*$")
    url = Regex.run(regex, link) |> List.last
    :binary.replace(url, "&url=", "")
  end

  defp parse_body(body) do
    body
    |> :jsx.decode
    |> Enum.map(fn ({k, v}) -> {String.to_atom(k), v} end)
  end
  
end
