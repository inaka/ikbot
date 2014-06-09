defmodule Ikbot do
  use Application.Behaviour

  def start(_type, args) do
    Ikbot.Sup.start_link(args)
  end
end