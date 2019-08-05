defmodule Seelies.MixProject do
  use Mix.Project

  def project do
    [
      app: :seelies,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env)
    ]
  end


  def application do
    [
      extra_applications: [:logger, :eventstore],
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
      {:commanded_scheduler, "~> 0.2"},
      {:eventstore, "~> 0.17"},
      {:commanded_eventstore_adapter, "~> 0.6"}
    ]
  end


  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
