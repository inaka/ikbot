defmodule Ikbot.Task do
  def process_message(message) do
    Task.Supervisor.async(:task_supervisor, fn -> do_process_message(message) end)
  end
  
  def do_process_message(message) do
    {mod, fun} = get_action(message)
    reply = 
      case {Kernel.function_exported?(mod, fun, 1), mod, fun} do
        {true, Ikbot.Script.Base, :say} ->
          apply(mod, fun, [remove_words(message, 2)])
        {true, _, _} ->
          apply(mod, fun, [remove_words(message, 3)])
        {false, _, _} ->
          Ikbot.Script.Image.me(remove_words(message, 1))
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

  defp get_action([dirty_task_name | task_args]) do
    task_name = clean_task_name(dirty_task_name)
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

  defp remove_words(message, n) do
    new_body = message.body
    |> String.split
    |> nthtail(n)
    |> Enum.join(" ")
    Map.put(message, :body, new_body)
  end

  defp nthtail([], _), do: []
  defp nthtail(list, 0), do: list
  defp nthtail([_head | tail], n), do: nthtail(tail, n - 1)

  defp clean_task_name(task_name) do
    Regex.replace(~r/(:|\.|,)/, task_name, "")
  end

end