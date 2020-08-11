defmodule KvStore.Supervisor do
  use Supervisor

  def start_link([]),
    do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  @impl true
  def init([]) do
    tcp_port_server = Application.get_env(:kv_store, :ports)[:tcp_port_server]
    udp_port_server = Application.get_env(:kv_store, :ports)[:udp_port_server]

    :ranch.start_listener(
      make_ref(),
      :ranch_tcp,
      [{:port, tcp_port_server}],
      KvStore.TcpServer,
      []
    )

    children = [
      KvStoreWeb.Endpoint,
      KvStore.Manager,
      {KvStore.UdpServer, udp_port_server}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
