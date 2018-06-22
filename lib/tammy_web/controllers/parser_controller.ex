defmodule TammyWeb.ParserController do
  use TammyWeb, :controller

  alias Tammy.Parser

  def parse_and_forward(conn, params) do
    Parser.call(params)

    conn
    |> put_status(:ok)
    |> json(:ok)
  end
end
