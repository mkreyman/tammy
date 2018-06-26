defmodule TammyWeb.ParserController do
  use TammyWeb, :controller

  require Logger

  alias Tammy.{Filter, Parser, Email, Mailer}

  def handle_call(conn, params) do
    with {:match, updated_params} <- Filter.match_recipient(params) do
      email =
        updated_params
        |> Parser.normalize()
        |> Email.compose()

      Mailer.deliver_later(email)
      Logger.info("Queued for delivery: \n#{inspect(email)}")
    else
      {:no_match, to, map} ->
        Logger.info(
          "Uknown email address #{inspect(to)} in translation map #{inspect(map)} -- Message dropped!"
        )
    end

    conn
    |> put_status(:ok)
    |> json(:ok)
  end
end
