defmodule KvStore.TcpUdpTest do
  use KvStoreWeb.ConnCase

  alias KvStoreWeb.Benchmark.ClientManager

  @test_port 2222

  setup do
    {:ok, pid} = ClientManager.start_link(@test_port)
    %{pid: pid}
  end

  describe "put,get and get by id from the store by TCP" do
    @put_data "PUT tcp_key_1 tcp_value_1"
    @get_data "GET tcp_key_1"

    @invalid_data "INVALID data"
    @missing_key "GET some_key"

    test "put and get from the store by TCP", setup do
      assert ClientManager.tcp_send(setup.pid, @put_data) == :ok
      assert ClientManager.tcp_read(setup.pid) == "added"

      assert ClientManager.tcp_send(setup.pid, @get_data) == :ok
      assert ClientManager.tcp_read(setup.pid) == "tcp_value_1"
    end

    test "renders errors when invalid data is posted by TCP", setup do
      assert ClientManager.tcp_send(setup.pid, @invalid_data) == :ok
      assert ClientManager.tcp_read(setup.pid) == "unknown command"
    end

    test "renders errors when key is missing", setup do
      assert ClientManager.tcp_send(setup.pid, @missing_key) == :ok
      assert ClientManager.tcp_read(setup.pid) == "not found"
    end
  end

  describe "put,get and get by id from the store by UDP" do
    @put_data "PUT udp_key_1 udp_value_1"
    @get_data "GET udp_key_1"

    @invalid_data "INVALID data"
    @missing_key "GET some_key"

    test "put and get from the store by UDP", setup do
      assert ClientManager.udp_send(setup.pid, @put_data) == :ok
      assert ClientManager.udp_read(setup.pid) == 'added'

      assert ClientManager.udp_send(setup.pid, @get_data) == :ok
      assert ClientManager.udp_read(setup.pid) == 'udp_value_1'
    end

    test "renders errors when invalid data is posted by UDP", setup do
      assert ClientManager.udp_send(setup.pid, @invalid_data) == :ok
      assert ClientManager.udp_read(setup.pid) == 'unknown command'
    end

    test "renders errors when key is missing", setup do
      assert ClientManager.udp_send(setup.pid, @missing_key) == :ok
      assert ClientManager.udp_read(setup.pid) == 'not found'
    end
  end
end
