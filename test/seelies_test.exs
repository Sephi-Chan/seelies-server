defmodule SeeliesTest do
  use Seelies.Test.DataCase


  test "Game can be started" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board()})
  end


  test "Game ID must be unique" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board()})
    {:error, :game_already_exists} = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board()})
  end


  test "Game can be stopped" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board()})
    :ok = Seelies.Router.dispatch(%Seelies.StopGame{game_id: "42"})
    catch_exit(Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42"))
  end


  test "Resources can be added to a territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{silver: 500, gold: 100}})

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.Game.resources(game, "t1").gold == 100
    assert Seelies.Game.resources(game, "t1").silver == 500
    assert Seelies.Game.resources(game, "t1").bronze == 0
  end
end
