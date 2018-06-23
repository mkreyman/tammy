defmodule Tammy.Filter do
  @translation_map Application.get_env(:tammy, :filter)

  def match_recipient(%{"envelope" => envelope} = params) do
    %{"from" => from, "to" => [to | _]} = Poison.decode!(envelope)
    params = %{params | "to" => to, "from" => from}

    with translation_map <- decode(@translation_map),
         nil <- translation_map[to] do
      {:no_match, to, translation_map}
    else
      forwarder -> {:match, %{params | "to" => forwarder}}
    end
  end

  def decode(var) do
    with {:ok, translation_map} <- Poison.decode(var) do
      translation_map
    else
      _ -> %{}
    end
  end
end
