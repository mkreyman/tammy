defmodule Tammy.Parser do
  alias Tammy.{Email, Mailer}

  require Logger

  @translation_map System.get_env("SENDGRID_FORWARDERS") ||
                     "{\"to@example.com\":\"forward@example.com\"}"

  def call(params) do
    params = decode_envelope(params)

    case replace_to_in(params) do
      {:match, updated_params} ->
        normalize(%{}, updated_params)
        |> Email.compose()
        |> Mailer.deliver_later()

      {:no_match, to, translation_map} ->
        Logger.info(
          "Uknown email address #{inspect(to)} in translation map #{inspect(translation_map)} -- Message dropped!"
        )
    end
  end

  defp normalize(%{} = email, params) do
    email
    |> put_envelope(params)
    |> put_subject(params)
    |> put_html_body(params)
    |> put_text_body(params)
    |> put_attachments(params)
  end

  defp decode_envelope(%{"envelope" => envelope} = params) do
    %{"from" => from, "to" => [to | _]} = Poison.decode!(envelope)
    %{params | "envelope" => %{"to" => to, "from" => from}}
  end

  defp replace_to_in(%{"envelope" => %{"to" => to, "from" => from}} = params) do
    translation_map = decode_var(@translation_map)

    case translation_map[to] do
      nil -> {:no_match, to, translation_map}
      forwarder -> {:match, %{params | "envelope" => %{"to" => forwarder, "from" => from}}}
    end
  end

  defp decode_var(json) do
    case Poison.decode(json) do
      {:ok, translation_map} -> translation_map
      _ -> %{}
    end
  end

  defp put_envelope(email, %{"envelope" => %{"from" => from, "to" => to}}) do
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
