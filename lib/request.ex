defmodule Kogia.Request do
  @moduledoc false
  alias Kogia.Model.Error

  @default_headers [
                      {"Accept", "application/json"},
                      {"Content-Type", "application/json"}
                   ]
  @put_header [{"Content-Type", "application/x-tar"}]

  @api_version "/v1.22"

  def get(client, path, headers \\ @default_headers), do: request(client, :get, path, "", headers)
  def delete(client, path, headers \\ @default_headers), do: request(client, :delete, path, "", headers)
  def post(client, path, body \\ "{}", headers \\ @default_headers), do: request(client, :post, path, body, headers)
  def put(client, path, body \\ "{}", headers \\ @put_header), do: request(client, :put, path, body, headers)

  def request(client, method, path, body \\ "", headers \\ @default_headers, options \\ []) do
    url = client.server <> @api_version <> path
    options = Keyword.merge(options, [
      hackney: [ssl_options: client.ssl_options]
    ])
    case HTTPoison.request(method, url, body, headers, options) do
      {:ok, response} -> body_parser(response)
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, %Error{reason: reason}}
    end
  end

  def stream_request(client, method, path, body \\ "", headers \\ @default_headers, options \\ []) do
    url = client.server <> @api_version <> path
    task = Task.async(fn ->
      options = Keyword.merge(options, [
        hackney: [ssl_options: client.ssl_options],
        recv_timeout: 60_000,
        stream_to: self
      ])
      {:ok, %HTTPoison.AsyncResponse{}} = HTTPoison.request(method, url, body, headers, options)
      stream_loop_json(nil, [])
    end)
    case Task.yield(task, :infinity) do
      {:ok, data} -> data
      {:error, reason} -> {:error, %Error{reason: reason}}
    end
  end

  @doc """
  Returns a `GenEvent.Stream` that consume from streaming endpoint.
  """
  @spec stream(Client.t, Atom.t, String.t, Map.t, Keyword.t) :: {:ok, GenEvent.Stream.t} | {:error, HTTPoison.Error.t}
  def stream(client, method, path, body \\ "", headers \\ @default_headers, options \\ []) do
    url = client.server <> @api_version <> path
    options = Keyword.merge(options, [
        hackney: [ssl_options: client.ssl_options],
        recv_timeout: 60_000
      ])
    {:ok, listener} = GenEvent.start_link()
    case HTTPoison.request(method, url, body, headers, options ++ [stream_to: spawn(fn -> stream_loop(listener) end)]) do
      {:ok, %HTTPoison.AsyncResponse{id: id}} ->
        GenEvent.add_handler(listener, Kogia.StreamHandler, id)
        {:ok, GenEvent.stream(listener)}
      {:error, error} ->
        {:error, error}
    end
  end

  defp stream_loop(listener, _buffer \\ "", _size \\ 0) do
    receive do
      %HTTPoison.AsyncChunk{chunk: chunk} ->
            [h, t] = String.split(chunk, "\r\n", parts: 2)
            GenEvent.ack_notify(listener, h)
      _ -> :noop
    end
    stream_loop(listener)
  end

  defp stream_loop_json(status, acc) do
    receive do
      %HTTPoison.AsyncStatus{code: new_status} -> stream_loop_json(new_status, acc)
      %HTTPoison.AsyncHeaders{}                -> stream_loop_json(status, acc)
      %HTTPoison.AsyncChunk{chunk: chunk}      -> stream_loop_json(status, [Poison.decode!(chunk)|acc])
      %HTTPoison.AsyncEnd{}                    -> {:ok, Enum.reverse(acc)}
      %HTTPoison.Error{reason: reason}         -> {:error, %Error{reason: reason}}
    after 30_000                               -> {:error, "Request timed out"}
    end
  end

  defp body_parser(%HTTPoison.Response{body: "", status_code: status_code}) when status_code < 400, do: {:ok, status_code}
  defp body_parser(%HTTPoison.Response{body: body, status_code: status_code}) when status_code >= 400 do
    %Error{reason: body}
  end
  defp body_parser(%HTTPoison.Response{headers: headers, body: body}) do
    case List.keyfind(headers, "Content-Type", 0) do
      {"Content-Type", "application/json"} -> Poison.decode!(body, keys: :atoms!)
      {"Content-Type", "application/vnd.docker.raw-stream"} -> [headers, body]
      {"Content-Type", "text/plain; charset=utf-8"} -> body
      {"Content-Type", "application/x-tar"} -> [headers, body]
      _ -> [headers, body]
    end
  end

end
