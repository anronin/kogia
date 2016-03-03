defmodule Kogia.Misc do
  @moduledoc false
  alias Kogia.Request, as: R

  @doc """
  Create a new image from a container’s changes

  Json Parameters:

  * `container` - the container’s configuration

  Query Parameters:

  * `container` – source container
  * `repo` – repository
  * `tag` – tag
  * `comment` – commit message
  * `author` – author (e.g., “John Hannibal Smith <hannibal@a-team.com>“)
  * `pause` – 1/True/true or 0/False/false, whether to pause the
              container before committing
  * `changes` – Dockerfile instructions to apply while committing
  """
  @spec commit(Map.t, Map.t, Client.t) :: Map.t
  def commit(container, params, client) do
    R.post(client, "/commit?" <> URI.encode_query(params), container)
  end

  @doc """
  Sets up an *exec instance* in a running container `id`
  """
  @spec exec_create(String.t | Map.t, Map.t, Client.t) :: Map.t
  def exec_create(container, params, client) when is_map(container), do: exec_create(container["Id"], params, client)
  def exec_create(container, params, client) do
    params = Poison.encode!(params)
    R.post(client, "/containers/#{container}/exec", params)
  end

  @doc """
  Starts a previously set up *exec instance* `id`. If detach is true,
  this API returns after starting the exec command. Otherwise, this API
  sets up an interactive session with the exec command.
  """
  @spec exec_start(String.t | Map.t, Map.t, Client.t) :: Map.t
  def exec_start(task, params, client) when is_map(task), do: exec_start(task["Id"], params, client)
  def exec_start(task, params, client) do
    params = Poison.encode!(params)
    R.post(client, "/exec/#{task}/start", params)
  end

  @doc """
  Return low-level information about the `exec` command `id`
  """
  @spec exec_inspect(String.t | Map.t, Client.t) :: Map.t
  def exec_inspect(task, client) when is_map(task), do: exec_inspect(task["Id"], client)
  def exec_inspect(task, client) do
    R.get(client, "/exec/#{task}/json")
  end

  @doc """
  Resizes the `tty` session used by the `exec` command `id`. The unit is
  number of characters. This API is valid only if `tty` was specified as
  part of the `exec_create` and the `exec_start` commands.

  Params:
    * `h` – height of tty session
    * `w` – width

  Example: `%{h: 80, w: 40}`
  """
  @spec exec_resize(String.t | Map.t, Map.t, Client.t) :: String.t
  def exec_resize(task, params, client) when is_map(task), do: exec_resize(task["Id"], params, client)
  def exec_resize(task, params, client) do
    R.post(client, "/exec/#{task}/resize?" <> URI.encode_query(params))
  end

  @doc """
  Get a `tarball` containing all images and metadata for the repository
  specified by `name`.

  If name is a specific name and tag (e.g. `ubuntu:latest`), then only that
  image (and its parents) are returned. If name is an image ID, similarly
  only that image (and its parents) are returned, but with the exclusion of
  the *repositories* file in the tarball, as there were no image
  names referenced.

  * `filename` - The file to export the data to.
  """
  @spec get_image(Client.t, String.t, String.t) :: :ok | {:error, Error.t}
  def get_image(client, name, filename) do
    data =
        client
        |> R.get("/images/#{name}/get")
        |> List.last
    File.write(filename, data)
  end

  @doc """
  Get a `binary stream data` containing all images and metadata for one or
  more repositories. One can save it to tarball.

  For each value of the names parameter: if it is a specific name and
  tag (e.g. `ubuntu:latest`), then only that image (and its parents) are
  returned; if it is an image ID, similarly only that image (and its parents)
  are returned and there would be no names referenced in the ‘repositories’
  file for this image ID.
  """
  @spec get_image(Client.t, Map.t) :: String.t | {:error, Error.t}
  def get_image(client, params) do
    client
    |> R.get("/images/get?" <> URI.encode_query(params))
    |> List.last
  end

  @doc """
  Info on the Docker host
  """
  @spec info(Client.t) :: Map.t
  def info(client) do
    R.get(client, "/info")
  end

  @doc """
  Load a set of images and tags into a Docker repository

  * `filename` - path to file in `Image tarball format`

      *** WIP ***
  """
  @spec load(Client.t, String.t) :: [] | {:error, Error.t}
  def load(client, filename) do
    R.stream_request(client, :post, "/images/load", File.read!(filename))
  end

  @spec login(Map.t, Client.t) :: Map.t
  def login(params, client) do
    R.post(client, "/auth", Poison.encode!(params))
  end

  @doc """
  Ping the Docker host
  """
  @spec ping(Client.t) :: String.t
  def ping(client) do
    R.get(client, "/_ping")
  end

  @doc """
  Version information of the Docker host
  """
  @spec version(Client.t) :: Map.t
  def version(client) do
    R.get(client, "/version")
  end

  # def auth(_client), do: throw :not_implemented_yet
  # def build(_client), do: throw :not_implemented_yet
  # def auth(_client), do: throw :not_implemented_yet
  # def events(_client), do: throw :not_implemented_yet
end
