defmodule SeeliesTest do
  use InMemoryEventStoreCase


  test "Game can be started" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
  end


  test "Resources can be added to a territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{silver: 500, gold: 100}})

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.Game.resources(game, "t1").gold == 100
    assert Seelies.Game.resources(game, "t1").silver == 500
    assert Seelies.Game.resources(game, "t1").bronze == 0
  end


  test "Resources quantities can be added" do
    quantity = Seelies.ResourcesQuantity.add(%{silver: 300, gold: 200}, %{bronze: 100, silver: 200})
    assert quantity.bronze == 100
    assert quantity.silver == 500
    assert quantity.gold == 200
  end


  test "Resources quantities can be substracted" do
    quantity = Seelies.ResourcesQuantity.substract(%{bronze: 1000, silver: 300, gold: 200}, %{silver: 100, gold: 200})
    assert quantity.bronze == 1000
    assert quantity.silver == 200
    assert quantity.gold == 0
  end


  def board() do
    alias Seelies.Board
    Board.new()
      |> Board.add_area("a1")
      |> Board.add_area("a2")
      |> Board.add_area("a3")
      |> Board.add_area("a4")
      |> Board.add_deposit("a1", "d1", :gold)
      |> Board.add_deposit("a1", "d2", :silver)
      |> Board.add_deposit("a2", "d3", :gold)
      |> Board.add_deposit("a3", "d4", :gold)
      |> Board.add_deposit("a4", "d5", :silver)
      |> Board.add_territory("t1", ["a1", "a2"])
      |> Board.add_territory("t2", ["a2", "a3"])
      |> Board.add_territory("t3", ["a3", "a4"])
      |> Board.add_territory("t4", ["a2", "a3", "a4"])
      |> Board.add_territory("t5", ["a1", "a2", "a4"])
      |> Board.add_route("t1", "t2", 9)
      |> Board.add_route("t1", "t3", 15)
      |> Board.add_route("t1", "t5", 5)
      |> Board.add_route("t2", "t3", 4)
      |> Board.add_route("t2", "t4", 4)
      |> Board.add_route("t3", "t4", 2)
      |> Board.add_route("t3", "t5", 5)
      |> Board.add_route("t4", "t5", 1)
  end
end
