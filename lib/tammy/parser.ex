defmodule Tammy.Parser do

  alias __MODULE__, warn: false
  alias Tammy.Email

  # Need to replicate... https://github.com/thoughtbot/griddler-sendgrid/blob/master/lib/griddler/sendgrid/adapter.rb
  # ...and implement: https://github.com/thoughtbot/bamboo#handling-recipients

  def normalize(%Email{} = struct, params) do
    struct
    |> put_from(params)
    |> put_to(params)
    # |> put_cc(params)
    # |> put_bcc(params)
    |> put_subject(params)
    |> put_html_body(params)
    |> put_text_body(params)
    # |> put_attachments(params)
    
    #   to: recipients(:to).map(&:format),
    #   cc: recipients(:cc).map(&:format),
    #   bcc: get_bcc,
    #   attachments: attachment_files,
    #   charsets: charsets,
    #   spam_report: {
    #     report: params[:spam_report],
    #     score: params[:spam_score],
    #   }
  end

  defp put_from(struct, %{"from" => from}) do
    Map.put(struct, :from, to_address(from))
  end

  defp put_to(struct, %{"to" => to}) do
    put_addresses(struct, :to, to)
  end

  defp put_cc(struct, %{"cc" => []}), do: struct

  defp put_cc(struct, %{"cc" => cc}) do
    put_addresses(struct, :cc, cc)
  end

  defp put_bcc(struct, %{"bcc" => []}), do: struct

  defp put_bcc(struct, %{"bcc" => bcc}) do
    put_addresses(struct, :bcc, bcc)
  end

  defp put_subject(struct, %{"subject" => subject}) when not is_nil(subject) do
    Map.put(struct, :subject, subject)
  end

  defp put_subject(struct, _), do: struct

  defp put_html_body(struct, %{"html" => nil}), do: struct

  defp put_html_body(struct, %{"html" => html_body}) do
    %{struct | html_body: html_body}
  end

  defp put_text_body(struct, %{"text" => nil}), do: struct

  defp put_text_body(struct, %{"text" => text_body}) do
    %{struct | text_body: text_body}
  end

  defp put_attachments(struct, %{"attachment-info" => []}), do: struct

  defp put_attachments(struct, %{"attachment-info" => attachments}) do
    transformed =
      attachments
      |> Enum.reverse()
      |> Enum.map(fn attachment ->
        %{
          filename: attachment.filename,
          type: attachment.content_type,
          content: Base.encode64(attachment.data)
        }
      end)

    Map.put(struct, :attachments, transformed)
  end

  defp put_addresses(struct, _, []), do: struct

  defp put_addresses(struct, field, addresses) when is_binary(addresses) do
    addresses = String.split(addresses, ", ")
    Map.put(struct, field, Enum.map(addresses, &to_address/1))
  end

  defp put_addresses(struct, field, addresses) do
    Map.put(struct, field, Enum.map(addresses, &to_address/1))
  end

  defp to_address({nil, address}), do: %{email: address}
  defp to_address({"", address}), do: %{email: address}
  defp to_address({name, address}), do: %{email: address, name: name}
  defp to_address(email) when is_binary(email), do: %{email: email}

  # defp to_address(email) when is_binary(email) do
  #   [name, address] = String.split(email, " ")
  #   %{email: address, name: name}
  # end
end