defmodule Tammy.Parser do
  def normalize(%{} = email, params) do
    email
    |> put_envelope(params)
    |> put_subject(params)
    |> put_html_body(params)
    |> put_text_body(params)
    |> put_attachments(params)
  end

  defp put_envelope(email, %{"envelope" => envelope}) do
    %{"from" => from, "to" => [to | _]} = Poison.decode!(envelope)

    email
    |> Map.put(:from, from)
    |> Map.put(:to, to)
  end

  defp put_subject(email, %{"subject" => subject}) when not is_nil(subject) do
    Map.put(email, :subject, subject)
  end

  defp put_subject(email, _), do: email

  defp put_html_body(email, %{"html" => nil}), do: email

  defp put_html_body(email, %{"html" => html_body}) do
    Map.put(email, :html_body, html_body)
  end

  defp put_text_body(email, %{"text" => nil}), do: email

  defp put_text_body(email, %{"text" => text_body}) do
    Map.put(email, :text_body, text_body)
  end

  defp put_attachments(email, params) do
    case files = find_attachments(params) do
      [] -> email
      _ -> email |> Map.put(:attachments, []) |> attach(files, [])
    end
  end

  defp find_attachments(params) do
    Enum.filter(params, fn element ->
      match?({_, %Plug.Upload{}}, element)
    end)
    |> Enum.map(fn {_, v} -> v end)
  end

  defp attach(email, [], _), do: email

  defp attach(email, [file | files], attachments) do
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
