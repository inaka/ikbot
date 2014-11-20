defmodule Ikbot.Hipchat do
  alias Ikbot.Task
  use Hedwig.Handler

  @valid_mentions ["@ikbot", "ikbot"]

  def handle_event(%Message{} = message, opts) do
    case has_valid_mention?(message) do
      false -> :ok
      true -> Task.process_message(message)
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

  def handle_info({_from, {:unknown_message, message}}, opts) do
    IO.puts "unknown_message: #{message.body}"
    {:ok, opts}
  end

  def handle_info(msg, opts) do
    IO.puts "handle_info"
    IO.inspect msg
    {:ok, opts}
  end

  defp has_valid_mention?(message) do
    message.body
    |> String.strip
    |> String.starts_with? @valid_mentions
  end
end