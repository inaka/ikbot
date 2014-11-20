defmodule Ikbot.Script.Heroku do
  alias HTTPotion.Response

  def base message do
    status message
  end

  def status _message do
    case HTTPotion.get("https://status.heroku.com/api/v3/current-status", [], []) do
      %Response{body: body, status_code: 200} ->
        "/code #{body}"
      %Response{status_code: status_code} ->
        "Sorry. Something went wrong (code: #{status_code})"
    end
  end
end