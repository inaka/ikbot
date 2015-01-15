defmodule Ikbot.Task do
  def process_message(message) do
    Task.Supervisor.async :task_supervisor, fn ->
      reply = get_reply_from_script(message)
      {:send_reply, message, reply}
    end
  end
  
  def get_reply_from_script(message) do
    case Ikbot.Script.module_by_message(message) do
      :undefined ->
        Ikbot.Script.Base.run(message)
      module ->
        module.run(message)
    end
  end

end