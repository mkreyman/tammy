defmodule Tammy.Email do
  import Bamboo.Email

  alias __MODULE__, warn: false

    defstruct from: nil,
              to: nil,
              cc: nil,
              bcc: nil,
              subject: nil,
              html_body: nil,
              text_body: nil,
              attachments: []

  def compose(%Email{} = email) do
    email
    |> Map.from_struct
    |> new_email()
  end
end