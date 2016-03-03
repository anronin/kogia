defmodule Kogia.Mixfile do
  use Mix.Project

  def project do
    [app: :kogia,
     version: "0.0.1",
     elixir: "~> 1.2",
     description: "An Elixir client for the Docker Remote API",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:httpoison]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.11.4", only: :docs},
      {:earmark, "~> 0.2.1", only: :docs},
      {:credo, "~> 0.3", only: [:dev, :test]},
      {:poison, "~> 2.0"},
      {:httpoison, "~> 0.8.1"}
    ]
  end

  defp package do
    [maintainers: ["anronin"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/anronin/kogia"}]
  end
end
