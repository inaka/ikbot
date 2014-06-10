defmodule Ikbot.Worker do
  use GenServer

  def start_link args do
    GenServer.start_link(__MODULE__, args)
  end
  

  def init args do
    {:ok, :empty_state}
  end
  
end