defmodule Ikbot.Script.Base do
  alias Ikbot.Script.Base
  alias Ikbot.Script

  def run(message) do
    try do
      [function | rest] = String.split(message.body)
      apply(Base, String.to_atom(function), [Enum.join(rest, " ")])
    rescue
      MatchError ->
        "Hi. I'm a bot. try sending 'ikbot help'"
      UndefinedFunctionError ->
        "I'm sorry. My responses are limited. You must ask the right questions."
    end
  end
  
  def say(""), do: "(wat) tell me something to say"
  def say(body), do: body

  def ping(_body), do: "pong"

  def help(_body) do
    scripts = Application.get_env(:ikbot, :scripts, [])
    enable_scripts =
      Enum.map_join scripts, "\n", fn script ->
        name = Script.get_name(script)
        triggers = Script.get_triggers(script)
        "* #{String.capitalize(name)} (triggers: #{Enum.join(triggers, ", ")})"
      end
    
    """
    Do you need help? These are the enabled scripts:
    #{enable_scripts}
    """
  end

  def thanks(""), do: "no problem"

  def thank("you"), do: "you're welcome"
        
end