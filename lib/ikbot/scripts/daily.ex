defmodule Ikbot.Script.Daily do
  alias HTTPotion.Response

  @doc ~S"""
  Returns a funny daily.
    ## Examples:

      iex> daily = Ikbot.Script.Daily.base %{}
      ...> "daily: I'm kinda busy. " <> text = daily
      ...> is_binary(text)
      :true
  
  """
  def base _message do
    case HTTPotion.get "http://pages.cs.wisc.edu/~ballard/bofh/excuses", [], [] do
      %Response{body: body, status_code: 200} ->
        dailies = String.split(body, "\n")
        :random.seed(:erlang.now)
        n = :random.uniform(Enum.count(dailies) - 1)
        {:ok, daily} = Enum.fetch(dailies, n)
        "daily: #{daily}. I'm working on that."
      %Response{status_code: status_code} ->
        "Sorry. Something went wrong (code: #{status_code})"
    end
  end
end