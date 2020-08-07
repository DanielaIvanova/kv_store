defmodule KvStore.Manager do
  @moduledoc """
  This module contains data manager implementation.
  """
  use GenServer

  alias KvStore.Store

  def start_link(_args), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def get(), do: GenServer.call(__MODULE__, :get)

  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})

  def init(state) do
    {:ok, state}
  end

  def handle_call(:get, _from, state) do
    result = for p <- Map.values(state), do: Store.get(p)
    {:reply, result, state}
  end

  def handle_call({:get, key}, _from, state) do
    error_msg = {:error, "not found"}

    {result, new_state} =
      with {:ok, pid} <- Map.fetch(state, key),
           true <- Process.alive?(pid) do
        {{:ok, Store.get(pid, key)}, state}
      else
        :error -> {error_msg, state}
        false -> {error_msg, Map.delete(state, key)}
      end

    {:reply, result, new_state}
  end

  def handle_cast({:put, key, value}, state) do
    new_state =
      with {:ok, pid} <- Map.fetch(state, key),
           true <- Process.alive?(pid) do
        Store.put(pid, key, value)
        state
      else
        :error ->
          {:ok, pid} = Store.start_link([])
          Store.put(pid, key, value)
          Map.put(state, key, pid)

        false ->
          Map.delete(state, key)
          {:ok, pid} = Store.start_link([])
          Store.put(pid, key, value)
          Map.put(state, key, pid)
      end

    {:noreply, new_state}
  end
end
