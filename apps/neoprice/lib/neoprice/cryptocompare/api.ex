defmodule NeoPrice.CryptoCompare.Api do
  @moduledoc false
  require Logger

  @url "min-api.cryptocompare.com"

  @app_name Application.get_env(:neo_price, :app_name, "neoscan")

  def get_pricehistorical_price(:minute, from_symbol, to_symbol, limit, to) do
    params = "fsym=#{from_symbol}&tsym=#{to_symbol}&limit=#{limit}&toTs=#{to}"
    params = params <> "&extraParams=#{@app_name}"
    HTTPoison.get("https://" <> @url <> "/data/histominute?" <> params)
    |> extract_data()
  end

  def get_pricehistorical_price(:hour, from_symbol, to_symbol, limit, to) do
    params = "fsym=#{from_symbol}&tsym=#{to_symbol}&limit=#{limit}&toTs=#{to}"
    params = params <> "&aggregate=1&e=CCCAGG&extraParams=#{@app_name}"
    HTTPoison.get("https://" <> @url <> "/data/histohour?" <> params)
    |> extract_data()
  end

  defp extract_data({:ok, %{status_code: 200, body: body}}) do
    case Poison.decode(body) do
      {:ok, %{"Data" => data}} ->
        Enum.map(data, fn(%{"open" => value, "time" => time}) ->
          {time, value}
        end)
      _ -> Logger.warn fn ->
        "Couldn't decode json #{body}"
      end
      []
    end
  end

  defp extract_data(_) do
    Logger.warn("Http error")
    []
  end
end
