defmodule Ikbot.Script.Pivotal do
  use Exredis.Api

  alias HTTPotion.Response

  # Api

  def base(message) do
    help(message)
  end

  def help(_message) do
    """
    To start to use it, you first need to associate a project to this room.\n
    Commands:
    ikbot pivotal help - Display this message
    ikbot pivotal set project PROJECT_ID - Associate a project to this room
    ikbot pivotal assign STORY_DESCRIPTION to @some_user @someone_else - Create and assign a new story
    """
  end  

  def set(message) do
     %{body: "project " <> project_id} = message
    case project_exists?(project_id) do
      false ->
        "Is it a valid project id? Because I think it's not."
      true ->
        %{from: %Hedwig.JID{user: room, resource: creator}} = message
        associate_project(project_id, room)

        "(successful) #{creator}, done. Now you can create stories from this room."
    end
  end

  def assign(message) do
    try do
      %{from: %Hedwig.JID{user: room, resource: creator}, body: body} = message
      
      project_id = project_id(room)
      [owner_mentions, story_name] = parse_body(:assign, body)

      owner_ids = Enum.map(
        owner_mentions,
        fn(owner_mention) ->
          hipchat_user = hipchat_user(owner_mention)
          pivotal_user = pivotal_user(hipchat_user[:email], project_id)
          pivotal_user[:id]
        end
      )
      
      {:created, story} = create_story(story_name, project_id, owner_ids)
      
      "(successful) #{creator}, done. I created the story #{story[:id]}: " <>
      "\"#{story_name}\" #{story[:url]} and I assigned it to " <>
      Enum.join(owner_mentions, " ")
    catch
      error -> error
    end
  end

  # Helpers

  defp project_id(room) do
    key = redis_key(room)
    case redis_client |> get(key) do
      :undefined ->
        error = """
        Did you set the project for this room? Because I think you didn't.
        Send `ikbot pivotal help` to learn more.
        """
        throw(error)
      project_id ->
        project_id
    end
  end

  defp parse_body(:assign, body) do
    parsed_body =
      body
      |> String.split("to")
      |> Enum.reverse

    case parsed_body do
      [owners | reversed_story] when owners != "" and reversed_story != [] ->
        owner_mentions = String.split(owners)
        story_name =
          reversed_story
          |> Enum.reverse
          |> Enum.join("to")
          |> String.strip
        [owner_mentions, story_name]
      _ ->
        error = """
        There's something wrong in your message.
        Send `ikbot pivotal help` to learn more.
        """
        throw(error)
    end
  end

  defp hipchat_user(mention) do
    url = Enum.join([hipchat_host, "/v2/user/", mention, "?auth_token=", hipchat_api_token])
    case HTTPotion.get(url, [], []) do
      %Response{status_code: 200, body: body} ->
        parse_req_body(body)
      _ ->
        error = "I can't find the user #{mention} in Hipchat"
        throw(error)
    end
  end

  defp pivotal_user(email, project_id) do
    pivotal_user =
      project_id
      |> project_users
      |> Enum.find(fn(user) -> user[:email] == email end)
    
    error = "I can't find the user with email #{email} in your project"
    if is_nil(pivotal_user), do: throw(error)

    pivotal_user
  end

  defp create_story(story_name, project_id, owner_ids) do
    url = Enum.join([host, "services/v5/projects/", project_id, "/stories"])
    headers = [auth_header, {"Content-Type", "application/json"}]
    body = %{
      name: story_name,
      owner_ids: owner_ids
    }

    case HTTPotion.post(url, :jsx.encode(body), headers) do
      %Response{status_code: 200, body: body} ->
        story = parse_req_body(body)
        {:created, story}
      req_error ->
        IO.inspect req_error
        error = "Something went wrong creating the story. Contact your support team"
        throw(error)
    end    
  end

  defp project_exists?(project_id) do
    url = Enum.join([host, "services/v5/projects/", project_id])
    case HTTPotion.get(url, [auth_header], []) do
      %Response{status_code: 200} ->
        true
      _ ->
        false
    end
  end

  defp project_users(project_id) do
    url = Enum.join([host, "services/v5/projects/", project_id, "/memberships"])
    case HTTPotion.get(url, [auth_header], []) do
      %Response{status_code: 200, body: body} ->
        body
        |> parse_req_body
        |> Enum.map(
            fn(member) -> 
              Enum.map(
                member[:person],
                fn ({k, v}) -> {String.to_atom(k), v} end
              )
            end
          )
      req_error ->
        IO.inspect req_error
        error = "Something went wrong getting the project users. Contact your support team"
        throw(error)
    end
  end

  defp associate_project(project_id, room) do
    key = redis_key(room)
    redis_client |> set(key, project_id)
  end

  defp parse_req_body(body) do
    body
    |> :jsx.decode
    |> Enum.map(
        fn ({k, v}) ->
          {String.to_atom(k), v}
        (properties) when is_list(properties) ->
          Enum.map(properties, fn ({k, v}) -> {String.to_atom(k), v} end)
        end
      )
  end

  defp host do
    "https://www.pivotaltracker.com/"
  end
  
  defp auth_header do
    {:ok, %{api_token: api_token}} = :application.get_env(:ikbot, :pivotal)
    {"X-TrackerToken", api_token}
  end

  defp hipchat_host do
    "http://api.hipchat.com"
  end

  defp hipchat_api_token do
    {:ok, token} = :application.get_env(:ikbot, :hipchat_api_token)
    token
  end

  defp redis_key(room) do
    Enum.join(["ikbot:scripts:pivotal:room:", room])
  end

  defp redis_client do
    ensure_redis_agent
    Agent.get(:redis_client, fn client -> client end)
  end

  defp ensure_redis_agent do
    case Process.whereis(:redis_client) do
      pid when is_pid(pid) ->
        :cool
      nil ->
        {:ok, pid} = Agent.start_link(fn -> Exredis.start end)
        true = Process.register(pid, :redis_client)
    end
  end
end