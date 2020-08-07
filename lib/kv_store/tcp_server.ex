defmodule KvStore.TcpServer do
  use GenServer

  alias KvStore.Util

  @behaviour :ranch_protocol

  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  def init(ref, socket, transport) do
    {:ok, ^socket} = :ranch.handshake(ref)
    :ok = transport.setopts(socket, [{:active, true}])
    :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport})
  end

  def handle_info({:tcp, socket, data}, state = %{socket: socket, transport: transport}) do
    response = Util.process(data)
    transport.send(socket, response)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state = %{socket: socket, transport: transport}) do
    transport.close(socket)
    {:stop, :normal, state}
  end
end
