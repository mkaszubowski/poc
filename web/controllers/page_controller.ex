defmodule Poc.PageController do
  use Poc.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def uploads(conn, _params) do
    render(conn, "uploads.html")
  end
end
