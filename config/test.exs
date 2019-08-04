import Config

config :commanded,
event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :commanded, Commanded.EventStore.Adapters.InMemory,
  serializer: Commanded.Serialization.JsonSerializer

config :logger, level: :warn

config :mix_test_watch, clear: true

config :seelies, Seelies.Repo,
  database: "seelies_test",
  username: "seelies",
  password: "b?t>J0yD{8<1",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

  config :eventstore, EventStore.Storage,
    serializer: Commanded.Serialization.JsonSerializer,
    username: "seelies",
    password: "b?t>J0yD{8<1",
    database: "seelies_test",
    hostname: "localhost",
    pool_size: 10

# config :commanded_scheduler, Commanded.Scheduler.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   database: "seelies_test",
#   username: "seelies",
#   password: "b?t>J0yD{8<1",
#   hostname: "localhost",
#   pool_size: 1
