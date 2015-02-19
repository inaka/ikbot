defmodule Ikbot.Script.Pong do
  def base(_message) do
    ranking()
  end

  def ranking do
    spawn fn ->
      :os.cmd('cd ./deps/pong; ./run.sh')
    end
    "(pingpong) processing results ..."
  end
  

end