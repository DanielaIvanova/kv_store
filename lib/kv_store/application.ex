defmodule KvStore.Application do
  use Application

  def start(_type, _args) do
    children = [KvStore.Supervisor]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end

  def config_change(changed, _new, removed) do
    KvStoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
