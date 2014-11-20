defmodule Ikbot do
  use Application

  def start(_type, args) do
    load_scripts
    Ikbot.Supervisor.start_link(args)
  end

  defp load_scripts do
    Enum.each Application.get_env(:ikbot, :scripts), fn(script) ->
      Code.require_file "lib/ikbot/scripts/#{script}.ex"
    end
  end
end