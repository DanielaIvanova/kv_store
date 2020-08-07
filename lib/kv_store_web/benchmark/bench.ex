defmodule Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4000/"
  plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON

  def build_request(path, :get, []), do: get(path)

  def build_request(path, :get, id), do: get(path <> "/" <> id)

  def build_request(path, :post, args), do: post(path, args)
end

defmodule Mix.Tasks.Bench do
  use Mix.Task

  alias KvStoreWeb.Benchmark.{Aggregator, ClientManager}

  @init_client_port 2020

  @prоtocols [:tcp, :udp, :GET, :POST]

  # tests should have these keys set, beforehand
  @init %{
    " predefined_k1" => " predefined_v1",
    " predefined_k2" => " predefined_k2",
    " predefined_k3" => " predefined_v3"
  }

  @get_opts ["", "predefined_k1", "predefined_k2", "predefined_k3"]

  @post_opts [
    %{"key" => "key1", "value" => "value1"},
    %{"key" => "key2", "value" => "value2"},
    %{"key" => "key3", "value" => "value3"}
  ]
  @tcp_udp_commands ["PUT", "GET"]

  @tcp_udp_put [
    " tcp_udp_key1 tcp_udp_val1",
    " tcp_udp_key2 tcp_udp_val2",
    " tcp_udp_key3 tcp_udp_val3"
  ]
  @tcp_udp_get [" predefined_k1", " predefined_k2", " predefined_k3"]

  def run(arg) do
    init_store(@init)

    pids =
      hd(arg)
      |> String.to_integer()
      |> Aggregator.spawn_process()

    info = gen_scenario() |> Aggregator.execute(pids)

    Enum.each(info, fn {k, v} ->
      total_requests = hd(arg) |> String.to_integer()
      responses = v[:response]
      total_exec_time = Enum.sum(v[:time]) / 1000
      min = min(v[:time]) / 1000
      max = max(v[:time]) / 1000
      average = total_exec_time / total_requests
      mean = (min + max) / 2

      percentiles = %{
        "50th" => percentile(v[:time], 50) / 1000,
        "80th" => percentile(v[:time], 80) / 1000,
        "90th" => percentile(v[:time], 90) / 1000,
        "99th" => percentile(v[:time], 99) / 1000
      }

      data = "
          Request: #{inspect(k)}
          Number of requests: #{inspect(total_requests)}
          Responses: #{inspect(responses)}
          Total execution time: #{inspect(total_exec_time)} ms
          Min exec time: #{inspect(min)} ms
          Max exec time: #{inspect(max)} ms
          Average: #{inspect(average)} ms
          Mean: #{inspect(mean)} ms
          Percentiles:
            50th: #{inspect(percentiles["50th"])} ms
            80th: #{inspect(percentiles["80th"])} ms
            90th: #{inspect(percentiles["90th"])} ms
            99th: #{inspect(percentiles["99th"])} ms
          ......................................................................
          "
      Mix.shell().info(data)
    end)
  end

  defp percentile([], _), do: nil
  defp percentile([x], _), do: x
  defp percentile(list, 0), do: min(list)
  defp percentile(list, 100), do: max(list)

  defp percentile(list, n) when is_list(list) and is_number(n) do
    s = Enum.sort(list)
    r = n / 100.0 * (length(list) - 1)
    f = :erlang.trunc(r)
    lower = Enum.at(s, f)
    upper = Enum.at(s, f + 1)
    lower + (upper - lower) * (r - f)
  end

  defp min([]), do: nil

  defp min(list) do
    Enum.min(list)
  end

  defp max([]), do: nil

  defp max(list) do
    Enum.max(list)
  end

  defp init_store(data) do
    {:ok, pid} = ClientManager.start_link(@init_client_port)

    Enum.each(data, fn {k, v} ->
      ClientManager.tcp_send(pid, "PUT" <> k <> v)
      ClientManager.tcp_read(pid)
    end)
  end

  defp gen_scenario(), do: for(_n <- 1..10, do: gen_step())

  defp gen_step() do
    protocol = Enum.random(@prоtocols)
    command = gen_command(protocol)

    opts =
      case protocol do
        :tcp -> gen_opts(protocol, command)
        :udp -> gen_opts(protocol, command)
        _ -> gen_opts(protocol)
      end

    {protocol, command, opts}
  end

  defp gen_command(:GET), do: "/get"

  defp gen_command(:POST), do: "/put"

  defp gen_command(:tcp), do: Enum.random(@tcp_udp_commands)

  defp gen_command(:udp), do: Enum.random(@tcp_udp_commands)

  defp gen_opts(:tcp, "PUT"), do: Enum.random(@tcp_udp_put)

  defp gen_opts(:tcp, "GET"), do: Enum.random(@tcp_udp_get)

  defp gen_opts(:udp, "PUT"), do: Enum.random(@tcp_udp_put)

  defp gen_opts(:udp, "GET"), do: Enum.random(@tcp_udp_get)

  defp gen_opts(:GET), do: Enum.random(@get_opts)

  defp gen_opts(:POST), do: Enum.random(@post_opts)
end
