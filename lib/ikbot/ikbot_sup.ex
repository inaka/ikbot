defmodule Ikbot.Sup do
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      supervisor(Ikbot.ListenerSup, []),
      supervisor(Ikbot.NotifierSup, []),
      supervisor(Ikbot.WorkerSup, [])
    ]
    supervise children, strategy: :one_for_one
  end
end