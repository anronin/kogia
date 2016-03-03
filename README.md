# Kogia

An Elixir client for the Docker Remote API.
Based on DockerAPI.ex https://github.com/JonGretar/DockerAPI.ex

#### Usage

Add `kogia` to your `mix.exs`

```elixir
  defp deps do
    [
      {:kogia, git: "https://github.com/anronin/kogia.git"}
    ]   
  end
```

Make sure it gets started

```elixir
  def application do
    [applications: [:logger, :kogia]]
  end
```
