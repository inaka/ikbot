defmodule Ikbot.Script.Devops do
  alias HTTPotion.Response

  def base _message do
    case HTTPotion.get("http://devopsreactions.tumblr.com/random", [], []) do
      %Response{headers: headers, status_code: 302, body: body} ->
        location = headers[:Location]
        {title, url} = get_info(location)
        "#{title} #{url}"
      %Response{status_code: status_code} ->
        "Sorry. Something went wrong (code: #{status_code})"
    end
  end

  defp get_info(location) do
    [location_url | _] = String.split(location, "#")
    case HTTPotion.get(location_url) do
      %Response{headers: headers, body: body, status_code: 200} ->
        title = get_title(body)
        url = get_url(body)
        {title, url}
      %Response{status_code: status_code} ->
        {"Sorry. Something went wrong (code: #{status_code})", ""}
    end
  end

  defp get_title(body) do
    {:ok, reg1} = Regex.compile("class=\\\"post_title\\\">.*</a>")
    {:ok, reg2} = Regex.compile("class=\\\"post_title\\\"><a .*\">|</a>")
    [tag | _] = Regex.run(reg1, body)
    String.replace(tag, reg2, "")
  end

  defp get_url(body) do
    {:ok, regex} = Regex.compile("src=.*.gif")
    [img_tag | _] = Regex.run(regex, body)
    String.replace(img_tag, "src=\"", "")
  end
end