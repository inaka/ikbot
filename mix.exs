defmodule Ikbot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ikbot,
      version: "0.0.1",
      elixir: "1.0.0",
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
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
      {:httpotion, "~> 0.2.0"},
      {:hedwig, github: "scrogson/hedwig"}
    ]
  end
end