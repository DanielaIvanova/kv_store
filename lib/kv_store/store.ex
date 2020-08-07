defmodule KvStore.Store do
  @moduledoc """
  This module provides simple API for data isolating and instancing.
  """
  use Agent

  def start_link(_args), do: Agent.start_link(fn -> %{} end)

  def get(pid), do: Agent.get(pid, &Map.values(&1))

  def get(pid, key), do: Agent.get(pid, &Map.get(&1, key))

  def put(pid, key, value), do: Agent.update(pid, &Map.put(&1, key, value))
end
