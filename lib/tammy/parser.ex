defmodule Tammy.Parser do
  def normalize(
        %{"from" => from, "to" => to, "subject" => subject, "html" => html, "text" => text} =
          params
      ) do
    %{from: from, to: to, subject: subject, html_body: html, text_body: text, attachments: nil}
    |> put_attachments(params)
  end

  defp put_attachments(%{} = email, params) do
    with [] <- find_attachments(params) do
      email
    else
      files -> attach(email, files, [])
    end
  end

  defp find_attachments(params) do
    Enum.filter(params, fn element ->
      match?({_, %Plug.Upload{}}, element)
    end)
    |> Enum.map(fn {_, v} -> v end)
  end

  defp attach(%{} = email, [], _), do: email

  defp attach(%{} = email, [file | files], attachments) do
    email = %{
      email
      | attachments: [
          Bamboo.Attachment.new(
            file.path,
            filename: file.filename,
            content_type: file.content_type
          )
          | attachments
        ]
    }

    attach(email, files, email[:attachments])
  end
end
