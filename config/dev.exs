import Config

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "seelies",
  password: "b?t>J0yD{8<1",
  database: "seelies_event_store_dev",
  hostname: "localhost",
  pool_size: 10

config :seelies, Seelies.Repo,
  database: "seelies_dev",
  username: "seelies",
  password: "b?t>J0yD{8<1",
  hostname: "localhost"

config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "seelies_commanded_scheduler_dev",
  username: "seelies",
  password: "b?t>J0yD{8<1",
  hostname: "localhost",
  pool_size: 1

config :mix_test_watch,
  clear: true
