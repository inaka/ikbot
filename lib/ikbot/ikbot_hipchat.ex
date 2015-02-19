defmodule Ikbot.Hipchat do
  alias Ikbot.Task
  use Hedwig.Handler

  @valid_mentions ["@ikbot", "ikbot"]

  def init_keepalive do
    Enum.each Application.get_env(:hedwig, :clients), fn(%{jid: jid}) ->
      %{event_manager: pid} = jid |> String.to_atom |> Process.whereis |> :sys.get_state
      GenEvent.notify(pid, :init_keepalive)
    end
  end

  def handle_event(%Message{} = message, opts) do
    case has_valid_mention?(message) do
      false -> :ok
      true -> Task.process_message(message)
    end
    {:ok, opts}
  end

  def handle_event(:init_keepalive, opts) do
    delay = Application.get_env(:ikbot, :keepalive_delay)
    :erlang.send_after(delay, self, :send_keepalive)
    {:ok, opts}
  end

  def handle_event(_event, opts) do
    {:ok, opts}
  end

  def handle_info({_from, {:send_reply, message, reply}}, opts) do
    reply(message, Stanza.body(reply))
    {:ok, opts}
  end

  def handle_info(:send_keepalive, opts) do
    pid = opts.client.jid |> String.to_atom |> Process.whereis
    client = Hedwig.Client.client_for(opts.client.jid)

    stanza = Hedwig.Stanza.join(hd(client.rooms), client.nickname)
    Hedwig.Client.reply(pid, stanza)

    delay = Application.get_env(:ikbot, :keepalive_delay)
    :erlang.send_after(delay, self, :send_keepalive)
    {:ok, opts}
  end

  def handle_info(_msg, opts) do
    {:ok, opts}
  end

  defp has_valid_mention?(message) do
    message.body
    |> String.strip
    |> String.starts_with? @valid_mentions
  end
end
