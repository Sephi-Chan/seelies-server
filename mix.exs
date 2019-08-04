defmodule Seelies.MixProject do
  use Mix.Project

  def project do
    [
      app: :seelies,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end


  def application do
    [
      extra_applications: [:logger],
      mod: {Seelies.Application, []}
    ]
  end


  defp deps do
    [
      {:commanded, "~> 0.19"},
      {:jason, "~> 1.1"},
      {:mix_test_watch, "~> 0.8", only: [:test, :dev], runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:commanded_scheduler, "~> 0.2"}
    ]
  end
end
