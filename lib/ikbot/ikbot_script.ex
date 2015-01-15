defmodule Ikbot.Script do
  def get_name(script) do
    get(script, :name)
  end

  def get_triggers(script) do
    get(script, :triggers)
  end

  def module_by_message(message) do
    scripts = Application.get_env(:ikbot, :scripts, [])
    case Enum.filter(scripts, &is_triggered_by?(&1, message)) do
      [] ->
        :undefined
      [script | _] ->
        module = script |> get_name |> String.capitalize
        Module.concat([Ikbot, Script, module])
    end
  end

  def is_triggered_by?(script, %{body: message_body}) do
    triggers = get_triggers(script)
    String.starts_with?(message_body, triggers)
  end
  
  defp get(script_name, attr) when is_atom(script_name) do
    get({script_name, []}, attr)
  end  
  defp get({name, _options}, :name) do
    name |> to_string
  end
  defp get({name, options}, :triggers) do
    name = name |> to_string
    {:triggers, triggers} = List.keyfind(options, :triggers, 0, {:triggers, [name]})
    triggers
  end

end