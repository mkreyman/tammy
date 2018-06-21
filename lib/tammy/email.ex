defmodule Tammy.Email do
  import Bamboo.Email

  def compose(email = %{}) do
    new_email(email)
  end
end
