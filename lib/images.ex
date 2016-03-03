defmodule Kogia.Images do
  @moduledoc false
  alias Kogia.Request, as: R

  @doc """
  Create an image either by pulling it from the registry or by importing it
  """
  @spec create(Map.t, Client.t) :: :ok
  def create(params, client) do
    R.stream_request(client, :post, "/images/create?" <> URI.encode_query(params), "")
  end

  @doc """
  Create an image by pulling it from the registry

  Same as doing create(%{fromImage: "image", tag: "tag"}, client)
  """
  @spec create(String.t, String.t, Client.t) :: :ok
  def create(image, tag, client) do
    params = URI.encode_query(%{fromImage: image, tag: tag})
    R.stream_request(client, :post,  "/images/create?" <> params, "")
  end

  @doc """
  Remove the image `name` from the filesystem

  Query Parameters:

  * force – 1/True/true or 0/False/false, default false
  * noprune – 1/True/true or 0/False/false, default false
  """
  @spec delete(String.t, Map.t, Client.t) :: Map.t
  def delete(name, params \\ %{force: 0, noprune: 0}, client)
  def delete(name, params, client) do
    R.delete(client, "/images/#{name}?" <> URI.encode_query(params))
  end

  @doc """
  Return the history of the image `name`
  """
  @spec history(String.t, Client.t) :: Map.t
  def history(name, client) do
    R.get(client, "/images/#{name}/history")
  end

  @doc """
  List images
  """
  @spec list(Client.t) :: List.t
  def list(client) do
    R.get(client, "/images/json")
  end

  @doc """
  Return low-level information on the image `name`
  """
  @spec probe(String.t, Client.t) :: Map.t
  def probe(name, client) do
    R.get(client, "/images/#{name}/json")
  end

  @doc """
  Search for an image on Docker Hub.

  * `term` – term to search
  """
  @spec search(String.t, Client.t) :: List.t
  def search(term, client) do
    R.get(client, "/images/search?term=" <> term)
  end

  @doc """
  Tag the image `name` into a repository

  Query Parameters:

  * `repo` – The repository to tag in
  * `force` – 1/True/true or 0/False/false, default false
  * `tag` - The new tag name
  """
  @spec tag(String.t, Map.t, Client.t) :: Map.t
  def tag(name, params, client) do
    R.post(client, "/images/#{name}/tag?" <> URI.encode_query(params))
  end

  # def push(_client), do: throw :not_implemented_yet

end
