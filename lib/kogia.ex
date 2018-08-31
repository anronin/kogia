defmodule Kogia do
  @moduledoc false
  alias Kogia.Model.Client

  @doc """
  Creates a new connection.

  Tries to guess based on the DOCKER_HOST, DOCKER_TLS_VERIFY and
  DOCKER_CERT_PATH environment variables.
  """
  @spec connect() :: Client.t()
  def connect do
    case tls_verify() do
      "1" ->
        %Client{
          server: host_env() |> URI.parse() |> uri_to_string(false),
          ssl_options: [
            certfile: to_charlist(cert_path_env() <> "/cert.pem"),
            keyfile: to_charlist(cert_path_env() <> "/key.pem")
          ]
        }

      _ ->
        %Client{server: host_env() |> URI.parse() |> uri_to_string(false)}
    end
  end

  @doc """
  Creates a new connection.
  """
  @spec connect(String.t()) :: Client.t()
  def connect(server) do
    %Client{server: server, ssl_options: []}
  end

  @doc """
  Creates a new SSL connection.
  """
  @spec connect(String.t(), String.t(), String.t()) :: Client.t()
  def connect(server, certfile_path, keyfile_path) do
    %Client{
      server: server,
      ssl_options: [
        certfile: certfile_path,
        keyfile: keyfile_path
      ]
    }
  end

  defp host_env(), do: Application.get_env(:kogia, :host)
  defp cert_path_env(), do: Application.get_env(:kogia, :certpath)
  defp tls_verify(), do: Application.get_env(:kogia, :tls_verify)

  defp uri_to_string(uri, ssl_enabled \\ true) do
    uri = if ssl_enabled, do: %{uri | scheme: "https"}, else: %{uri | scheme: "http"}
    "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end
end
