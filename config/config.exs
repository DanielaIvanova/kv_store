# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :kv_store, KvStoreWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Q1sCgn512/WUhp1uNZtMg8i62yXsL6FH+AbRlmUTpm2F3sviO72jt7qS5Xar0WVS",
  render_errors: [view: KvStoreWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: KvStore.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "IT0naWlF"]

# Configures the ports
config :kv_store, :ports,
  tcp_port_server: 4040,
  udp_port_server: 4041

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
