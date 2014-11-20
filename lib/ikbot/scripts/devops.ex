defmodule Ikbot.Script.Devops do
  alias HTTPotion.Response

  def base _message do
    case HTTPotion.get("http://devopsreactions.tumblr.com/random", [], []) do
      %Response{headers: headers, status_code: 302} ->
        location = headers[:Location]
        title = get_title location
        url = get_url location
        "#{title}#{url}"
      %Response{status_code: status_code} ->
        "Sorry. Something went wrong (code: #{status_code})"
    end
  end

  defp get_title(location) do
    {:ok, regex} = Regex.compile("([a-z 0-9]|-)*#")
    [slug | _] = Regex.run(regex, location)
    String.replace(slug, ~r/-|#/, " ")
  end

  defp get_url(location) do
    [location_url | _] = String.split(location, "#")
    case HTTPotion.get(location_url) do
      %Response{body: body, status_code: 200} ->
        {:ok, regex} = Regex.compile("src=.*.gif")
        [img_tag | _] = Regex.run(regex, body)
        String.replace(img_tag, "src=\"", "")
      %Response{status_code: status_code} ->
        {"Sorry. Something went wrong (code: #{status_code})", ""}
    end
  end
end