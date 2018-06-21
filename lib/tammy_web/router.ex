defmodule TammyWeb.Router do
  use TammyWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", TammyWeb do
    pipe_through(:api)
  end

  if Mix.env() == :dev do
    # If using Phoenix
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end

  scope "/", TammyWeb do
    pipe_through(:api)

    post("/parse", ParserController, :parse_and_forward)
  end
end
