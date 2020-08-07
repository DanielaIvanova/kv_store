defmodule KvStoreWeb.StoreController do
  use KvStoreWeb, :controller

  alias KvStore.Manager
  import KvStore.Util

  def put(conn, %{"key" => key, "value" => value}), do: json(conn, Manager.put(key, value))

  def put(conn, _params), do: send_error(conn, :bad_request, "invalid format")

  def get(conn, %{"id" => key}) do
    case Manager.get(key) do
      {:error, error} ->
        send_error(conn, :not_found, error)

      {:ok, val} ->
        json(conn, val)
    end
  end

  def get(conn, _params), do: json(conn, Manager.get())
end
