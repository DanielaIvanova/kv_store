defmodule KvStoreWeb.StoreControllerTest do
  use KvStoreWeb.ConnCase

  describe "put,get and get by id from the store by REST" do
    @data1 %{"key" => "key1", "value" => "value1"}
    @data2 %{"key" => "key2", "value" => "value2"}
    @data3 %{"key" => "key3", "value" => "value3"}

    @invalid_data %{"key" => "value"}
    @missing_key "key4"

    test "put and get from the store", %{conn: conn} do
      conn = post(conn, Routes.store_path(conn, :put), @data1)
      assert json_response(conn, 200) == "ok"

      conn = get(conn, Routes.store_path(conn, :get, "key1"))
      assert json_response(conn, 200) == @data1["value"]

      conn = post(conn, Routes.store_path(conn, :put), @data2)
      assert json_response(conn, 200) == "ok"

      conn = get(conn, Routes.store_path(conn, :get, "key2"))
      assert json_response(conn, 200) == @data2["value"]

      conn = post(conn, Routes.store_path(conn, :put), @data3)
      assert json_response(conn, 200) == "ok"

      conn = get(conn, Routes.store_path(conn, :get, "key3"))
      assert json_response(conn, 200) == @data3["value"]
    end

    test "renders errors when invalid data is posted", %{conn: conn} do
      conn = post(conn, Routes.store_path(conn, :put), @invalid_data)
      assert json_response(conn, 400) == %{"error" => "invalid format"}
    end

    test "renders errors when key is missing", %{conn: conn} do
      conn = get(conn, Routes.store_path(conn, :get, @missing_key))
      assert json_response(conn, 404) == %{"error" => "not found"}
    end
  end
end
