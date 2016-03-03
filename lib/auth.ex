defmodule Kogia.Auth do
  @moduledoc false
  alias Kogia.Model.Auth

  @doc """
  Generate a Base64 encoded auth header from a struct
  """
  @spec encode_auth(Auth.t) :: String.t
  def encode_auth(auth) when is_map(auth) do
    auth |> Poison.encode! |> Base.encode64
  end

  @doc """
  Generate a Base64 encoded auth header from values
  """
  @spec encode_auth(username::String.t, password::String.t, email::String.t) :: base64::String.t
  def encode_auth(username, password, email) do
    %Auth{username: username, password: password, email: email}
    |> Poison.encode!
    |> Base.encode64
  end

end
