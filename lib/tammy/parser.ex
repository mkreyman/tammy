defmodule Tammy.Parser do
  alias Tammy.Email

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

  # defp put_attachments(email, %{"attachments" => []}), do: email

  # defp put_attachments(email, %{"attachments" => attachments}) do
  #   transformed =
  #     attachments
  #     |> Enum.reverse()
  #     |> Enum.map(fn attachment ->
  #       %{
  #         filename: attachment.filename,
  #         type: attachment.content_type,
  #         content: Base.encode64(attachment.data)
  #       }
  #     end)

  #   Map.put(email, :attachments, transformed)
  # end

  def put_attachments(email, params) do
    # attachment_count.times.map do |index|
    #   extract_file_at(index)
    # end

    attachment = extract_file_at(params, 0)
    email = Map.put(email, :attachments, attachments = [])

    %{email | attachments: [Bamboo.Attachment.new(attachment.path, filename: attachment.filename, content_type: attachment.content_type) | attachments]}
  end

  def attachment_count(%{"attachments" => nil}), do: 0
  def attachment_count(%{"attachments" => count}) do
    count
    |> String.trim
    |> String.to_integer
  end

  def extract_file_at(params, index) do
    file = attachment_file(params, index)
    case File.exists?(file.path) do
      true -> file
      _ -> nil
    end
  end

  def attachment_file(params, index) do
    attachment = "attachment#{index + 1}"
    params[attachment]
  end

  def attachment_info(%{"attachment-info" => nil}), do: %{}
  def attachment_info(%{"attachment-info" => attachment_info}) do
    Poison.decode!(attachment_info)
  end
end