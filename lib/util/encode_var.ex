defmodule Util.EncodeVar do
  @moduledoc """
    Encode a map with "to" to "forwarder" address translations; to be stored as $SENDGRID_FORWARDERS.
  """

  def encode_var(%{} = translation_map) do
    case Poison.encode(translation_map) do
      {:ok, json} -> json
      _ -> %{}
    end
  end
end
