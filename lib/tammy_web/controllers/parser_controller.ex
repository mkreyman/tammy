defmodule TammyWeb.ParserController do
  use TammyWeb, :controller

  alias Tammy.{Parser, Email, Mailer}

  def parse_and_forward(conn, params) do
    Parser.normalize(%Email{}, params)
    |> Email.compose()
    # |> Mailer.deliver_later()
    |> IO.inspect()

    conn
    |> put_status(:ok)
    |> json(:ok)
  end
end