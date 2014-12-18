defmodule Ikbot.Script.Base do
  @doc ~S"""
  Returns a simple message

  ## Examples:

      iex> Ikbot.Script.Base.base %{}
      "Did someone call me? (try '@ikbot help')"

  """
  def base(_message) do
    "Did someone call me? (try '@ikbot help')"
  end

  @doc ~S"""
  Receives a map.

  It returns the same message it receives.
  It returns a special message if the received message is empty.

  ## Examples:

      iex> Ikbot.Script.Base.say %{body: ""}
      "(wat) tell me something to say"

      iex> Ikbot.Script.Base.say %{body: ""}
      "this is a test"

  """
  def say(message) do
    case String.strip(message.body) do
      "" -> "(wat) tell me something to say"
      reply -> reply
    end
  end

  @doc ~S"""
  ## Examples:

      iex> Ikbot.Script.Base.ping %{body: ""}
      "pong"

  """
  def ping(_message) do
    "pong"
  end

  @doc ~S"""
  Returns the application help.

  ## Examples:

      iex> Ikbot.Script.Base.help %{body: ""}
      "Do you need help? not today. (shrug)"

  """
  def help(_message) do
    "Do you need help? not today. (shrug)"
  end

  def thank(message = %{body: body}) do
    IO.puts "MESSAGE 1"
    IO.inspect body
    body = String.strip(body)
    case body do
      "you" <> _ -> thanks(%{message | :body => ""})
      _ -> "that was for me?"
    end
  end

  def thanks(%{body: body}) do
    IO.puts "MESSAGE"
    IO.inspect body
    case String.strip(body) do
      "" -> "you're welcome"
      "." -> "you're welcome"
      _ -> "that was for me?"
    end
  end

end