import Config

config :seelies,
  ecto_repos: [Seelies.Repo, Commanded.Scheduler.Repo]

config :commanded_scheduler,
  router: Seelies.Router

config :eventstore, EventStore.Storage,
  serializer: Seelies.JsonSerializer

import_config "#{Mix.env()}.exs"
