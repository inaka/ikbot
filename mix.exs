defmodule Ikbot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ikbot,
      version: "0.0.1",
      elixir: "~>1.0",
      deps: deps
    ]
  end

  def application do
    [
      applications: [
        :httpotion,
        :hedwig
      ],
      mod: {Ikbot, []},
      env: []
    ]
  end

  defp deps do
    [
      {:jsx, github: "talentdeficit/jsx"},
      {:ibrowse, "~> 4.2"},
      {:httpotion, "~> 1.0"},
      {:hedwig, github: "scrogson/hedwig"},
      {:pong, github: "inaka/pong", branch: "elbrujohalcon.rank", compile: "", app: false},
      {:exredis, "0.1.0"}
    ]
  end
end
