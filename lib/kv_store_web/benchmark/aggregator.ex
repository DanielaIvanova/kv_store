defmodule KvStoreWeb.Benchmark.Aggregator do
  alias KvStoreWeb.Benchmark.Worker

  def spawn_process(n), do: spawn_process(n, [])

  def spawn_process(0, acc), do: acc

  def spawn_process(n, acc) do
    {:ok, pid} = Worker.start(String.to_integer("200#{n}"))
    spawn_process(n - 1, [pid | acc])
  end

  def execute(scenario, pids) do
    Enum.each(pids, fn pid ->
      Worker.prepare(pid, scenario)
    end)

    states = for p <- pids, do: Worker.state(p)

    for path <- scenario, into: %{} do
      {path, extract_values(states, path, %{response: [], time: []})}
    end
  end

  def extract_values([], _, acc), do: acc

  def extract_values([h | t], key, acc) do
    time = h.result[key].time
    response = h.result[key].response
    extract_values(t, key, response: [response | acc[:response]], time: [time | acc[:time]])
  end
end
