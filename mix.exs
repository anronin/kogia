defmodule Kogia.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kogia,
      version: "0.0.2",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "An Elixir client for the Docker Remote API",
      source_url: "https://github.com/anronin/kogia",
      package: package(),
      deps: deps()
    ]
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
      {:poison, "~> 3.0"},
      {:httpoison, "~> 1.0"}
    ]
  end

  defp package do
    [
      files: ["lib", "config", "mix.exs", "README.md"],
      maintainers: ["anronin"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/anronin/kogia"
      }
    ]
  end
end
