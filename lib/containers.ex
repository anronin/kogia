defmodule Kogia.Containers do
  @moduledoc false
  alias Kogia.Request, as: R

  def archive(container, path \\ "/" , client) do
    request = R.get(client, "/containers/#{container}/archive?path=" <> path)
    info = request
            |> List.first
            |> List.keyfind("X-Docker-Container-Path-Stat", 0)
            |> elem(1)
            |> Base.decode64!
            |> Poison.decode!
    data = request |> List.last
    [info, data]
  end

  @doc """
  Inspect changes on container id’s filesystem

  Values for `Kind`:

  * `0`: Modify
  * `1`: Add
  * `2`: Delete
  """
  @spec changes(Map.t, Client.t) :: Map.t
  def changes(container, client) when is_map(container), do: changes(container["Id"], client)
  def changes(container, client) do
    R.get(client, "/containers/#{container}/changes")
  end

  @doc """
  Create a container with a randomly generated name
  """
  @spec create(Map.t, Client.t) :: Map.t
  def create(container, client) do
    R.post(client, "/containers/create", Poison.encode!(container))
  end

  @doc """
  Create a container with a specific name.
  """
  @spec create(String.t, Map.t, Client.t) :: Map.t
  def create(name, container, client) do
    R.post(client, "/containers/create?name=" <> name, Poison.encode!(container))
  end

  @doc """
  Kill a running container
  """
  @spec kill(String.t | Map.t, Client.t) :: Map.t
  def kill(container, client) when is_map(container), do: kill(container["Id"], client)
  def kill(container, client) do
    R.post(client, "/containers/#{container}/kill")
  end

  @doc """
  List all containers
  """
  @spec list(Client.t) :: List.t
  def list(client) do
    R.get(client, "/containers/json?all=1")
  end

  @doc """
  List containers with Query Parameters

            *** WIP ***
  """
  @spec list(Client.t, Map.t, Map.t) :: List.t
  def list(client, filters \\ "" , params)
  def list(client, filters, params) do
    params = URI.encode_query(params)
     if filters != "" do
       filters = "filters=" <> Poison.encode!(filters)
     end
    R.get(client, "/containers/json?#{params}&" <> filters)
  end

  @doc """
  Pause the container
  """
  @spec pause(String.t | Map.t, Client.t) :: Map.t
  def pause(container, client) when is_map(container), do: pause(container["Id"], client)
  def pause(container, client) do
    R.post(client, "/containers/#{container}/pause")
  end

  @doc """
  Inspects a specific container

  Return low-level information on the container.
  """
  @spec probe(String.t | Map.t, Client.t) :: Map.t
  def probe(container, client) when is_map(container), do: probe(container["Id"], client)
  def probe(container, client) do
    R.get(client, "/containers/#{container}/json")
  end

  @doc """
  Upload a tar archive to be extracted to a path in the filesystem of container

  Query Parameters:

  * `path` - path to a directory in the container to extract the archive’s
    contents into. If not an absolute path, it is relative to the container’s
    root directory. The path resource must exist. *Required*

  * `noOverwriteDirNonDir` - If “1”, “true”, or “True” then it will be an
    error if unpacking the given content would cause an existing directory
    to be replaced with a non-directory and vice versa.
  """
  @spec put_archive(String.t | Map.t, Map.t, String.t, Client.t) :: Map.t
  def put_archive(container, params \\ %{path: "/"}, data, client)
  def put_archive(container, params, data, client) when is_map(container), do: put_archive(container["Id"], params, data, client)
  def put_archive(container, params, data, client) do
    params = URI.encode_query(params)
    R.put(client, "/containers/#{container}/archive?" <> params, data)
  end

  @doc """
  Restart a running container
  """
  @spec restart(String.t | Map.t, Client.t) :: Map.t
  def restart(container, client) when is_map(container), do: restart(container["Id"], client)
  def restart(container, client) do
    R.post(client, "/containers/#{container}/restart")
  end

  @doc """
  Create and start a container with a randomly generated name
  """
  @spec run(Map.t, Client.t) :: Map.t
  def run(container, client) do
    with %{"Id" => id} <- create(container, client),
          {:ok, 204} <- start(id, client),
      do: probe(id, client)
  end

  @doc """
  Create and start a container with a specific name.
  """
  @spec run(String.t, Map.t, Client.t) :: Map.t
  def run(name, container, client) do
    with %{"Id" => id} <- create(name, container, client),
          {:ok, 204} <- start(id, client),
      do: probe(id, client)
  end

  @doc """
  List processes running inside the container
  """
  @spec top(String.t | Map.t, Client.t) :: Map.t
  def top(container, client) when is_map(container), do: top(container["Id"], client)
  def top(container, client) do
    R.get(client, "/containers/#{container}/top")
  end

  @doc """
  Get a container’s resource usage statistics. Pull stats once then disconnect.

                *** WIP ***
  """
  @spec stats(Map.t, Client.t) :: Map.t
  def stats(container, client) when is_map(container), do: stats(container["Id"], client)
  def stats(container, client) do
    R.get(client, "/containers/#{container}/stats?stream=0")
  end

  @doc """
  Start a container in a stopped state
  """
  @spec start(String.t | Map.t, Client.t) :: Map.t
  def start(container, client) when is_map(container), do: start(container["Id"], client)
  def start(container, client) do
    R.post(client, "/containers/#{container}/start")
  end

  @doc """
  stop a container in a running state
  """
  @spec stop(String.t | Map.t, Client.t) :: Map.t
  def stop(container, client) when is_map(container), do: stop(container["Id"], client)
  def stop(container, client) do
    R.post(client, "/containers/#{container}/stop")
  end

  @doc """
  Rename the container id to a new_name
  """
  @spec rename(String.t | Map.t, String.t, Client.t) :: Map.t
  def rename(container, new_name, client) when is_map(container), do: rename(container["Id"], new_name, client)
  def rename(container, new_name, client) do
    R.post(client, "/containers/#{container}/rename?name=" <> new_name)
  end

  @doc """
  Remove the container id from the filesystem

  Optionally force kill the  container if it is running
  """
  @spec remove(String.t | Map.t, Map.t, Client.t) :: Map.t
  def remove(container, force \\ false, client)
  def remove(container, force, client) when is_map(container), do: remove(container["Id"], force, client)
  def remove(container, force, client) do
    R.delete(client, "/containers/#{container}?force=#{force}")
  end

  @doc """
  Unpause the container
  """
  @spec unpause(String.t | Map.t, Client.t) :: Map.t
  def unpause(container, client) when is_map(container), do: unpause(container["Id"], client)
  def unpause(container, client) do
    R.post(client, "/containers/#{container}/unpause")
  end

  @doc """
  Block until container `id` stops, then returns the exit code
  """
  @spec wait(String.t | Map.t, Client.t) :: Map.t
  def wait(container, client) when is_map(container), do: wait(container["Id"], client)
  def wait(container, client) do
    header = [{"Content-Type", "application/json"}]
    option = [recv_timeout: :infinity]
    R.request(client, :post, "/containers/#{container}/wait", "", header, option)
  end

  # def logs(_client), do: throw :not_implemented_yet
  # def export(_client), do: throw :not_implemented_yet
  # def resize(_client), do: throw :not_implemented_yet
  # def attach(_client), do: throw :not_implemented_yet
  # def attach_ws(_client), do: throw :not_implemented_yet

end
