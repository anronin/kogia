# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :kogia,
  host: System.get_env("DOCKER_HOST") || "https://127.0.0.1:4243",
  certpath: System.get_env("DOCKER_CERT_PATH") ||
            System.get_env("HOME")<>"/.docker",
  tls_verify: System.get_env("DOCKER_TLS_VERIFY ") || "1"

# import_config "#{Mix.env}.exs"
