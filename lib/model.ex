defmodule Kogia.Model do
  @moduledoc false
  defmodule Client do
    @moduledoc false
    defstruct ssl_options: [], server: nil
    @type t :: %Client{server: String.t, ssl_options: List.t}
  end

  defmodule Auth do
    @moduledoc false
    defstruct username: nil, password: nil, email: nil, auth: nil
    @type t :: %Auth{username: String.t, password: String.t, email: String.t, auth: String.t}
  end

  defmodule Error do
    @moduledoc false
    defexception reason: nil
    @type t :: %Error{reason: any}

    def message(%Error{reason: reason}), do: inspect(reason)
  end

end
