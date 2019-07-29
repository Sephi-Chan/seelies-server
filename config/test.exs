import Config

config :commanded, event_store_adapter: Commanded.EventStore.Adapters.InMemory
config :commanded, Commanded.EventStore.Adapters.InMemory, serializer: Commanded.Serialization.JsonSerializer

config :logger, level: :warn
config :mix_test_watch, clear: true
