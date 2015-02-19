defmodule Ikbot.Script.Xkcd do
  alias HTTPotion.Response

  def base _message do
    case HTTPotion.get("http://xkcd.com/info.0.json", [], []) do
      %Response{body: body, status_code: 200} ->
        body = parse_body(body)
        :random.seed(:os.timestamp())
        num = :random.uniform(body[:num])
        case HTTPotion.get("http://xkcd.com/#{num}/info.0.json", [], []) do
          %Response{body: body, status_code: 200} ->
            body = parse_body(body)
            "#{body[:title]} - #{body[:img]}"
          %Response{status_code: status_code} ->
            "Sorry. Something went wrong (code: #{status_code})"
        end
      %Response{status_code: status_code} ->
        "Sorry. Something went wrong (code: #{status_code})"
    end  
  end
  
  defp parse_body(body) do
    body
    |> :jsx.decode
    |> Enum.map(fn ({k, v}) -> {String.to_atom(k), v} end)
  end
end