import Config

# config :seelies, ecto_repos: [Seelies.Repo, Commanded.Scheduler.Repo]
config :seelies, ecto_repos: [Seelies.Repo]

# config :my_app, event_stores: [Seelies.EventStore]


import_config "#{Mix.env()}.exs"
