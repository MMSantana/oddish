defmodule OddishWeb.PageController do
  use OddishWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
