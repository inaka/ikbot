defmodule Ikbot.Script.Pong do
  def base(message) do
    ranking(message)
  end

  def ranking(message) do
    spawn fn ->
      :os.cmd('cd ./deps/pong; ./run.sh')
    end
    "(pingpong) processing results ..."
  end
  

end