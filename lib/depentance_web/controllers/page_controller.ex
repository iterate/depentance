defmodule DepentanceWeb.PageController do
  use DepentanceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
