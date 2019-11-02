# Seelies

Seelies is a strategy online game.

![A Seelies is a magical creature of the forest](https://raw.githubusercontent.com/Sephi-Chan/seelies-server/master/media/seelies.jpg)

The game is still under development. This repository hosts the server side of the application. There is no client yet.


## Running tests

Initialize the test environment once:

```
$ MIX_ENV=test mix do event_store.drop, ecto.drop
$ MIX_ENV=test mix do event_store.create, event_store.init, ecto.create, ecto.migrate
```

Run the tests:

```
$ mix test
```


## Running in a console

Start PostgreSQL :

```
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log  start
```

Initialize the environment once:

```
$ mix do event_store.drop, ecto.drop, event_store.create, event_store.init, ecto.create, ecto.migrate
```

Run the console:

```
$ iex -S mix
```

Seed some seed data:

game_id = Ecto.UUID.generate()
board = (
  Seelies.Board.new()
    |> Seelies.Board.add_area("a1")
    |> Seelies.Board.add_area("a2")
    |> Seelies.Board.add_area("a3")
    |> Seelies.Board.add_area("a4")
    |> Seelies.Board.add_deposit("a1", "d1", :gold)
    |> Seelies.Board.add_deposit("a1", "d2", :silver)
    |> Seelies.Board.add_deposit("a2", "d3", :gold)
    |> Seelies.Board.add_deposit("a3", "d4", :gold)
    |> Seelies.Board.add_deposit("a4", "d5", :silver)
    |> Seelies.Board.add_territory("t1", ["a1", "a2"])
    |> Seelies.Board.add_territory("t2", ["a2", "a3"])
    |> Seelies.Board.add_territory("t3", ["a3", "a4"])
    |> Seelies.Board.add_territory("t4", ["a2", "a3", "a4"])
    |> Seelies.Board.add_territory("t5", ["a1", "a2", "a4"])
    |> Seelies.Board.add_route("t1", "t2", 9)
    |> Seelies.Board.add_route("t1", "t3", 15)
    |> Seelies.Board.add_route("t1", "t5", 5)
    |> Seelies.Board.add_route("t2", "t3", 4)
    |> Seelies.Board.add_route("t2", "t4", 4)
    |> Seelies.Board.add_route("t3", "t4", 2)
    |> Seelies.Board.add_route("t3", "t5", 5)
    |> Seelies.Board.add_route("t4", "t5", 1)
)

Seelies.Router.dispatch(%Seelies.StartGame{game_id: game_id, board: board, teams: Seelies.Test.two_teams()})
Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: game_id, unit_id: "u1", territory_id: "t1", species: :ant})

game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, game_id)


game_id = "4aabf6ab-456d-4be9-97a8-9f997476f676"
