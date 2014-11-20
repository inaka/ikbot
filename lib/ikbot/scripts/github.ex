defmodule Ikbot.Script.Github do
  alias HTTPotion.Response

  @doc """
  Returns api/status.json response.
  """
  def base message do
    status message
  end

  def status _message do
    get("https://status.github.com/api/status.json")
  end

  def messages _message do
    get("https://status.github.com/api/messages.json")
  end

  def last_message _message do
    get("https://status.github.com/api/last-message.json")
  end

  defp get(url) do
    case HTTPotion.get(url, [], []) do
      %Response{body: body, status_code: 200} ->
        "/code #{body}"
      %Response{status_code: status_code} ->
        "Sorry. Something went wrong (code: #{status_code})"
    end
  end
end