# KvStore is In-Memory Key Value Store 

## Description
In-memory KvStore is an app written in Elixir. The store supports data storage and retrieval through TCP, UDP, and HTTP REST interfaces. The store caters for arbitrary data types.

All data that is received/sent is in binary/string format, so I decided to store data in binary format, as there is no need for additional data serialization/deserialization, as the data by itself internally is stored as strings, in a state of one simple data `Manager`, where for each new data, each time spawning a separate simple `Agent`, in which state we store the data. For data retrieval - if the given `key` exists, its value will be looked-up in the `Manager` state of isolated `Agents` and if the `pid` is alive, will write data to its state(re-writing existing state), and store the `pid` of corresponding `Agent` process in its state, otherwise will spawn new `Agent` with given `value` as the new state and `Manager` will put its `pid` at given new key .

## Data format

### For TCP/UDP:
- **PUT** some `key` under some `value`:
```
"PUT key value"
```
 Results in: `"added"` in success case, `"unknown command"` in error case.
- **GET** some `value` of some `key`:
```
"GET key"
```
Results in: `"value"` in success case, `"not found"` in error case.

 
### For HTTP REST:

- **GET**
  1. Endpoint: `/get/:id` , requires `id` , which should be an existing key in a key-value storage, example request :  `http://localhost:4000/get/key1` , responds with `value1` in success case , in error cases - responds with `404` status code and error message:`{"error":"not found"}`.
  2. Endpoint: `/get` , example request: `http://localhost:4000/get`, responds with list of all values from the store, if no values are in the store, respondes with empty list `"[]"`.

- **POST**
   1. Endpoint: `/put` , requires json, example request: `http://localhost:4000/put`, body: `{"key":"key1","value":"value1"}`, responds with `200` status code and `ok` in success case , in error cases - responds with `400` status code and error message `{"error":"invalid format"}}` 

## Prerequisites

Ensure that you have [Elixir](https://elixir-lang.org/install.html) installed.

## Usage
1. Clone the project:
```
git clone https://github.com/DanielaIvanova/kv_store
cd kv_store && mix deps.get && iex -S mix phx.server
```

### REST example

- POST
```
curl -d '{"key":"key1","value":"value1"}' -H "Content-Type: application/json" -X POST http://localhost:4000/put
```

- GET
```
curl -s "http://localhost:4000/get/key1"
```

---

**The project also comes with a simple TCP/UDP client implementations.**

### TCP/UDP client with example usage 

Connections manager should be spawned first: 
```elixir
{:ok, connection_pid} = KvStoreWeb.Benchmark.ClientManager.start_link(9000)
```
Where `9000` is a port that will be used for `TCP` and `UDP` connections. `UDP` will be spawned with `port+1000` port number.
The `ip address` is hardcoded and always is set to `{127,0,0,1}` for clients.

After it is spawned, now we can send messages by either `TCP` or `UDP`.

### TCP example usage
``` elixir
iex(1)> KvStoreWeb.Benchmark.ClientManager.tcp_send(connection_pid, "PUT key2 value2")
:ok
iex(2)> KvStoreWeb.Benchmark.ClientManager.tcp_read(connection_pid)
"added"
iex(3)> KvStoreWeb.Benchmark.ClientManager.tcp_send(connection_pid, "GET key2")
:ok
iex(4)> KvStoreWeb.Benchmark.ClientManager.tcp_read(connection_pid)
"value2"
```


### UDP example usage

``` elixir
iex(1)> KvStoreWeb.Benchmark.ClientManager.udp_send(connection_pid, "PUT key2 value2")
:ok
iex(2)> KvStoreWeb.Benchmark.ClientManager.udp_read(connection_pid)
'added'
iex(3)> KvStoreWeb.Benchmark.ClientManager.udp_send(connection_pid, "GET key2")
:ok
iex(4)> KvStoreWeb.Benchmark.ClientManager.udp_read(connection_pid)
'value2'
```

### TCP example with telnet client
```
telnet localhost 4040
PUT key3 value3
added 
GET key3
value3 
```

## Benchmark it!

This project also has a benchmarking functionality implemented. It's purpose is to test the availability and concurrency handling of the project. The benchmarking in this case would be spawning multiple clients, capable of making simultanious requests to the server at almost the same time, through TCP/UDP and HTTP REST. 

**In order to run benchmarking:**
The project should be up and running, then open a new shell and go to the project's root folder and execute next command:

``` elixir 
mix bench 5
```
Where `5` - is a number of clients, performing various TCP, UDP and REST requests to the server. At the end of the benchmarking, the output of detailed information is printed in a console.

The example output would look like:


```
          Request: {:POST, "/put", %{"key" => "key1", "value" => "value1"}}
          Number of requests: 5
          Responses: ["ok", "ok", "ok", "ok", "ok"]
          Total execution time: 36.218 ms
          Min exec time: 6.109 ms
          Max exec time: 11.057 ms
          Average: 7.243600000000001 ms
          Mean: 8.583 ms
          Percentiles:
            50th: 6.377 ms
            80th: 7.4386 ms
            90th: 9.2478 ms
            99th: 10.87608 ms
          ......................................................................
          

          Request: {:POST, "/put", %{"key" => "key3", "value" => "value3"}}
          Number of requests: 5
          Responses: ["ok", "ok", "ok", "ok", "ok"]
          Total execution time: 621.658 ms
          Min exec time: 124.292 ms
          Max exec time: 124.366 ms
          Average: 124.33160000000001 ms
          Mean: 124.32900000000001 ms
          Percentiles:
            50th: 124.333 ms
            80th: 124.3596 ms
            90th: 124.36280000000001 ms
            99th: 124.36568 ms
          ......................................................................
          

          Request: {:tcp, "PUT", " tcp_udp_key3 tcp_udp_val3"}
          Number of requests: 5
          Responses: ["added", "added", "added", "added", "added"]
          Total execution time: 1.856 ms
          Min exec time: 0.25 ms
          Max exec time: 0.438 ms
          Average: 0.37120000000000003 ms
          Mean: 0.344 ms
          Percentiles:
            50th: 0.395 ms
            80th: 0.4372 ms
            90th: 0.43760000000000004 ms
            99th: 0.43795999999999996 ms
          ......................................................................
          

          Request: {:udp, "GET", " predefined_k1"}
          Number of requests: 5
          Responses: ['predefined_v1', 'predefined_v1', 'predefined_v1', 'predefined_v1', 'predefined_v1']
          Total execution time: 1.582 ms
          Min exec time: 0.286 ms
          Max exec time: 0.365 ms
          Average: 0.3164 ms
          Mean: 0.3255 ms
          Percentiles:
            50th: 0.307 ms
            80th: 0.3362 ms
            90th: 0.3506 ms
            99th: 0.36356 ms
          ......................................................................
          

          Request: {:udp, "GET", " predefined_k3"}
          Number of requests: 5
          Responses: ['predefined_v3', 'predefined_v3', 'predefined_v3', 'predefined_v3', 'predefined_v3']
          Total execution time: 1.127 ms
          Min exec time: 0.189 ms
          Max exec time: 0.271 ms
          Average: 0.2254 ms
          Mean: 0.23 ms
          Percentiles:
            50th: 0.229 ms
            80th: 0.24620000000000003 ms
            90th: 0.2586 ms
            99th: 0.26976 ms
          ......................................................................
          

          Request: {:udp, "PUT", " tcp_udp_key1 tcp_udp_val1"}
          Number of requests: 5
          Responses: ['added', 'added', 'added', 'added', 'added']
          Total execution time: 1.245 ms
          Min exec time: 0.144 ms
          Max exec time: 0.411 ms
          Average: 0.24900000000000003 ms
          Mean: 0.27749999999999997 ms
          Percentiles:
            50th: 0.244 ms
            80th: 0.2918 ms
            90th: 0.35140000000000005 ms
            99th: 0.40503999999999996 ms
          ......................................................................
          

          Request: {:udp, "PUT", " tcp_udp_key3 tcp_udp_val3"}
          Number of requests: 5
          Responses: ['added', 'added', 'added', 'added', 'added']
          Total execution time: 1.572 ms
          Min exec time: 0.237 ms
          Max exec time: 0.487 ms
          Average: 0.3144 ms
          Mean: 0.362 ms
          Percentiles:
            50th: 0.273 ms
            80th: 0.355 ms
            90th: 0.421 ms
            99th: 0.4804 ms
          ......................................................................
```
