defmodule KvStore.UdpServer do
  use GenServer

  alias KvStore.Util

  def start_link(port), do: GenServer.start_link(__MODULE__, port)

  def init(port), do: :gen_udp.open(port, [:binary, active: true])

  def handle_info({:udp, _socket, _address, _port, "quit\n"}, socket) do
    :gen_udp.close(socket)
    {:stop, :normal, nil}
  end

  def handle_info({:udp, socket_client, address, port, data}, socket) do
    response = Util.process(data)
    :gen_udp.send(socket_client, {address, port}, response)
    {:noreply, socket}
  end
end
