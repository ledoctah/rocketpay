defmodule RocketpayWeb.HelloWorldController do
  use RocketpayWeb, :controller

  def index(conn, _params) do
    conn
      |> put_status(:ok)
      |> json(%{message: "Hello, world!"})
  end
end
