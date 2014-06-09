defmodule Ikbot.Mixfile do
  use Mix.Project

  def project do
    [app: :ikbot,
     version: "0.0.1",
     elixir: "~> 0.13.3",
     deps: deps]
  end

  def application do
    [
      applications: [],
      mod: {Ikbot, []}
    ]
  end

  defp deps do
    []
  end
end
