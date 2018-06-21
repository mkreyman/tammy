defmodule TammyWeb.ParserController do
  use TammyWeb, :controller

  alias Tammy.{Parser, Email, Mailer}

  def parse_and_forward(conn, params) do
    IO.inspect params

    Parser.normalize(%{}, params)
    |> Email.compose()
    |> Mailer.deliver_later()
    |> IO.inspect()

    conn
    |> put_status(:ok)
    |> json(:ok)
  end
end