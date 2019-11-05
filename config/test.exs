import Config

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :eventstore, EventStore.Storage,
  serializer: Seelies.JsonSerializer,
  username: "seelies",
  password: "b?t>J0yD{8<1",
  database: "seelies_event_store_test",
  hostname: "localhost",
  pool_size: 10

config :seelies, Seelies.Repo,
  database: "seelies_test",
  username: "seelies",
  password: "b?t>J0yD{8<1",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "seelies_commanded_scheduler_test",
  username: "seelies",
  password: "b?t>J0yD{8<1",
  hostname: "localhost",
  pool_size: 1

config :logger, level: :warn

config :mix_test_watch,
  clear: true
