defmodule KvStoreWeb.Benchmark.Worker do
  use GenServer

  alias KvStoreWeb.Benchmark.ClientManager

  def start(arg), do: GenServer.start(__MODULE__, arg)

  def state(pid), do: GenServer.call(pid, :state)

  def prepare(pid, scenario), do: GenServer.cast(pid, {:start, scenario})

  def init(arg) do
    {:ok, pid} = ClientManager.start_link(arg)
    {:ok, %{manager: pid}}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:start, scenario}, %{manager: pid} = state) do
    result =
      Enum.reduce(scenario, %{}, fn
        {:udp, req, arg} = data, acc ->
          {time, response} = :timer.tc(fn -> send_and_read(:udp, req <> arg, pid) end)
          Map.put(acc, data, %{time: time, response: response})

        {:tcp, req, arg} = data, acc ->
          {time, response} = :timer.tc(fn -> send_and_read(:tcp, req <> arg, pid) end)
          Map.put(acc, data, %{time: time, response: response})

        {:POST, req, arg} = info, acc ->
          fun = fn -> Client.build_request(req, :post, arg) end
          {time, {:ok, %Tesla.Env{body: body}}} = :timer.tc(fun)
          Map.put(acc, info, %{time: time, response: body})

        {:GET, req, arg} = info, acc ->
          fun = fn -> Client.build_request(req, :get, arg) end
          {time, {:ok, %Tesla.Env{body: body}}} = :timer.tc(fun)
          Map.put(acc, info, %{time: time, response: body})
      end)

    new_state = Map.put(state, :result, result)

    {:noreply, new_state}
  end

  defp send_and_read(:tcp, req, pid) do
    ClientManager.tcp_send(pid, req)
    ClientManager.tcp_read(pid)
  end

  defp send_and_read(:udp, req, pid) do
    ClientManager.udp_send(pid, req)
    ClientManager.udp_read(pid)
  end
end
