defmodule Ikbot.Script.Image do
  alias HTTPotion.Response

  def me(%{body: body})  do
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
        get_random_image(:proplists.get_value("results", body[:d]))
      %Response{status_code: status_code} ->
        "Sorry. Something went wrong (code: #{status_code})"
    end  
  end
  
  defp parse_body(body) do
    body
    |> :jsx.decode
    |> Enum.map(fn ({k, v}) -> {String.to_atom(k), v} end)
  end

  defp get_random_image([]) do
    "Image not found (sadpanda)"
  end

  defp get_random_image(results) do
    :random.seed(:os.timestamp)
    position = :random.uniform(length(results))
    result = Enum.at(results, (position - 1))
    image_url = :proplists.get_value("MediaUrl", result)

    case is_valid_image_url?(image_url) do
      false ->
        new_results = List.delete(results, result)
        get_random_image(new_results)
      true ->
        image_url
    end
  end

  defp is_valid_image_url?(image_url) do
    %Response{status_code: status_code} = HTTPotion.get(image_url)
    Enum.member?(200..210, status_code)
  end
end