defmodule KvStoreWeb.Benchmark.ClientManager do
  use GenServer

  @ip {127, 0, 0, 1}

  def start_link(port) do
    GenServer.start_link(__MODULE__, port)
  end

  def tcp_read(pid), do: GenServer.call(pid, :tcp_receive)
  def udp_read(pid), do: GenServer.call(pid, :udp_receive)

  def tcp_send(pid, data), do: GenServer.cast(pid, {:tcp_send, data})
  def udp_send(pid, data), do: GenServer.cast(pid, {:udp_send, data})

  def init(port) do
    tcp_port_server = Application.get_env(:kv_store, :ports)[:tcp_port_server]
    {:ok, tcp_socket} = :gen_tcp.connect(@ip, tcp_port_server, [:binary, active: false])
    {:ok, udp_socket} = :gen_udp.open(port + 1000, active: false)
    {:ok, %{tcp_pid: tcp_socket, udp_pid: udp_socket}}
  end

  def handle_call(:tcp_receive, _from, %{tcp_pid: tcp_socket} = state) do
    {:ok, data} = :gen_tcp.recv(tcp_socket, 0)
    {:reply, data, state}
  end

  def handle_call(:udp_receive, _from, %{udp_pid: udp_socket} = state) do
    {:ok, {_ip, _port, data}} = :gen_udp.recv(udp_socket, 0)
    {:reply, data, state}
  end

  def handle_cast({:tcp_send, data}, %{tcp_pid: tcp_socket} = state) do
    :gen_tcp.send(tcp_socket, data)
    {:noreply, state}
  end

  def handle_cast({:udp_send, data}, %{udp_pid: udp_socket} = state) do
    udp_port_server = Application.get_env(:kv_store, :ports)[:udp_port_server]
    :gen_udp.send(udp_socket, {@ip, udp_port_server}, data)
    {:noreply, state}
  end
end
