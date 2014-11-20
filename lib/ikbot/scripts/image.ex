defmodule Ikbot.Script.Image do
  alias HTTPotion.Response

  def me %{body: body}  do
    :random.seed(:os.timestamp)
    {:ok, %{key: key}} = :application.get_env(:ikbot, :bing)
    query_string = URI.encode_query([
      {"$format", "json"},
      {"Query", "'#{body}'"},
      {"$top", 20},
      {"$skip", 0}
    ])

    url = "https://api.datamarket.azure.com/Bing/Search/Image?#{query_string}" 
    ibrowse = [basic_auth: {key, key}]

    case HTTPotion.get(url, [], [ibrowse: ibrowse]) do  
      %Response{body: body, status_code: 200} ->
        body = parse_body(body)
        get_random_link(:proplists.get_value("results", body[:d]))
      %Response{status_code: status_code} ->
        "Sorry. Something went wrong (code: #{status_code})"
    end  
  end
  
  defp parse_body(body) do
    body
    |> :jsx.decode
    |> Enum.map(fn ({k, v}) -> {String.to_atom(k), v} end)
  end

  defp get_random_link([]) do
    "http://www.powersportbuys.com/images/xnothing_found.png.pagespeed.ic.ejFDpR-ph4.png"
  end
  defp get_random_link(results) do
    :random.seed(:os.timestamp)
    position = :random.uniform(length(results))
    result = Enum.at(results, (position - 1))
    :proplists.get_value("MediaUrl", result)
  end
end