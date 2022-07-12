defmodule Algernon.MixProject do
  use Mix.Project

  def project do
    [
      app: :algernon,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:axon, "~> 0.1.0"},
      {:csv, "~> 2.4"},
      {:exla, "~> 0.2.2"},
      {:nx, "~> 0.2.1"}
    ]
  end
end
