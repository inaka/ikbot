defmodule Ikbot.Task do
  def process_message(message) do
    Task.Supervisor.async(:task_supervisor, fn -> do_process_message(message) end)
  end
  
  def do_process_message(message) do
    {mod, fun} = get_action(message)
    reply = 
      case Kernel.function_exported?(mod, fun, 1) do
        true ->
          apply(mod, fun, [to_script_message(message)])
        false ->
          Ikbot.Script.Image.me(to_searchable_message(message))
      end
    {:send_reply, message, reply}
  end

  defp get_action(message) when is_map(message) do
    [_valid_mention | task] = String.split(message.body)
    get_action(task)
  end

  defp get_action([]) do
    {Ikbot.Script.Base, :base}
  end

  defp get_action([task_name | task_args]) do
    scripts = Application.get_env(:ikbot, :scripts)
    case Enum.member?(scripts, task_name) do
      :false ->
        {Ikbot.Script.Base, String.to_atom(task_name)}
      :true ->
        fun = get_fun(task_args)
        {Module.concat([Ikbot, Script, String.capitalize(task_name)]), fun}
    end    
  end

  defp get_fun([]) do
    :base
  end

  defp get_fun([function | _]) do
    String.to_atom(function)
  end

  defp to_script_message(message), do: Map.put(message, :body, clean_body(message.body))

  defp to_searchable_message(message), do: Map.put(message, :body, remove_mention(message.body))
  
  defp clean_body(body) do
    case String.split(body) do
      [_valid_mention, _module, _fun | new_body] -> Enum.join(new_body, " ")
      _ -> ""
    end
  end

  defp remove_mention(body) do
    body
    |> String.split
    |> tl
    |> Enum.join(" ")
  end

end