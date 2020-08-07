defmodule KvStore.Util do
  @moduledoc """
  Data processing module.
  """

  alias KvStore.Manager

  def process(data), do: data |> String.split() |> data_processing()

  def send_error(conn, status, reason) do
    conn
    |> Plug.Conn.put_status(status)
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Phoenix.Controller.json(%{"error" => reason})
  end

  defp data_processing(["PUT", key, value]) do
    Manager.put(key, value)
    "added"
  end

  defp data_processing(["GET", key]) do
    case Manager.get(key) do
      {:ok, data} -> data
      {:error, error} -> error
    end
  end

  defp data_processing(["GET"]) do
    case Manager.get() do
      {:ok, data} -> data
      {:error, error} -> error
    end
  end

  defp data_processing(_), do: "unknown command"
end
