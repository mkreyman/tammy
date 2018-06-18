defmodule Tammy.Email do
  import Bamboo.Email

  def welcome_email do
    new_email(
      to: "john@gmail.com",
      from: "support@myapp.com",
      subject: "Welcome to the app.",
      html_body: "<strong>Thanks for joining!</strong>",
      text_body: "Thanks for joining!"
    )

    # or pipe using Bamboo.Email functions
    # new_email
    # |> to("foo@example.com")
    # |> from("me@example.com")
    # |> subject("Welcome!!!")
    # |> html_body("<strong>Welcome</strong>")
    # |> text_body("welcome")
  end
end