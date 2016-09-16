defmodule Poc.PageController do
  use Poc.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
