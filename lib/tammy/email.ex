defmodule Tammy.Email do
  import Bamboo.Email

  @from_address Application.get_env(:tammy, :from_address)

  def compose(email) do
    email
    |> format()
    |> new_email()
  end

  defp format(%{} = email) do
    email
    |> html_body_to_attachment()
    |> prepend_orig_text_body()
    |> replace_orig_from()
  end

  defp html_body_to_attachment(%{html_body: nil} = email), do: email
  defp html_body_to_attachment(%{html_body: ""} = email), do: email

  defp html_body_to_attachment(%{html_body: html, attachments: attachments} = email) do
    %{email | attachments: [create_attachment(html) | attachments]}
  end

  defp prepend_orig_text_body(%{orig_from: orig_from, orig_to: orig_to, text_body: text} = email) do
    text = """
    \nThe following message was sent to you via SendGrid Inbound Parse API:

    FROM: #{orig_from}

    TO: #{orig_to}

    NOTE: For html formatted version, if there was any, please see attached html file.

    #{text}
    """

    email
    |> Map.put(:text_body, text)
    |> Map.delete(:html_body)
    |> Map.delete(:orig_from)
    |> Map.delete(:orig_to)
  end

  defp create_attachment(content) do
    {:ok, path} = Briefly.create()
    File.write!(path, content)

    Bamboo.Attachment.new(
      path,
      filename: Path.basename(path),
      content_type: "text/html"
    )
  end

  defp replace_orig_from(%{from: _} = email) do
    %{email | from: @from_address}
  end
end
