defmodule DepentanceWeb.Health.Plug do
  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{} = conn, _opts) do
    case conn.request_path do
      "/health" -> conn |> send_resp(200, "OK") |> halt()
      _ -> conn
    end
  end
end
