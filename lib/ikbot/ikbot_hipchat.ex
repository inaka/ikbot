defmodule Ikbot.Hipchat do
  alias Ikbot.Task
  use Hedwig.Handler
  
  def handle_event(%Message{} = message, opts) do
    case has_valid_mention?(message) do
      true ->
        message
        |> wipe_message
        |> Task.process_message
      false ->
        :ok
    end
    {:ok, opts}
  end

  def handle_event(_, opts) do
    {:ok, opts}
  end

  def handle_info({_from, {:send_reply, message, reply}}, opts) do
    reply(message, Stanza.body(reply))
    {:ok, opts}
  end

  def handle_info(_msg, opts) do
    {:ok, opts}
  end

  defp has_valid_mention?(message) do
    message.body
    |> String.strip
    |> String.starts_with? Ikbot.mention
  end

  def wipe_message(message) do
    new_body = 
      message.body
      |> String.replace(Ikbot.mention, "", global: false)
      |> String.strip
    Map.put(message, :body, new_body)
  end
end