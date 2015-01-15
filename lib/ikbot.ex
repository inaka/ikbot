defmodule Ikbot do
  use Application

  def start(_type, args) do
    Ikbot.Supervisor.start_link(args)
  end

  def mention do
    Application.get_env(:ikbot, :mention, "ikbot")
  end
end