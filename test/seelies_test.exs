defmodule SeeliesTest do
  use InMemoryEventStoreCase
  import Commanded.Assertions.EventAssertions


  test "Start a game" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
  end


  test "Can't deploy units to an nonexistent territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    {:error, :territory_not_found} = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1000", species: :ant})
  end


  test "Can't use a unit id twice" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "endive", territory_id: "t1", species: :ant})
    {:error, :unit_already_exists} = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "endive", territory_id: "t1", species: :ant})
  end


  test "Deploy an Starting unit to a territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})

    assert_receive_event(Seelies.StartingUnitDeployed, fn (event) ->
      assert event.game_id == "42"
      assert event.unit_id == "u1"
      assert event.territory_id == "t1"
      assert event.species == "ant"
    end)
  end


  test "Can't exploit a deposit from a distant area" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    {:error, :deposit_is_too_far} = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d5", time: 60 })
  end


  test "Can't exploit a nonexistent deposit" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    {:error, :deposit_not_found} = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1000", time: 60 })
  end


  test "Can't send a nonexistant unit to exploit a deposit" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    {:error, :unit_not_found} = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1000", deposit_id: "d1", time: 60 })
  end


  test "Unit starts exploiting the deposit" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })

    assert_receive_event(Seelies.UnitStartedExploitingDeposit, fn (event) ->
      assert event.game_id == "42"
      assert event.unit_id == "u1"
      assert event.deposit_id == "d1"
      assert event.time == 60
    end)
  end


  test "Unit can't be sent again if already exploiting" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })
    {:error, :already_exploiting_deposit} = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })
  end


  test "Stopping exploitation bring some resources back to the territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })
    :ok = Seelies.Router.dispatch(%Seelies.UnitStopsExploitingDeposit{game_id: "42", unit_id: "u1", time: 120 })
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })

    assert_receive_event(Seelies.UnitStoppedExploitingDeposit, fn (event) ->
      assert event.game_id == "42"
      assert event.unit_id == "u1"
      assert event.time == 120
    end)

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.Game.resources(game, "t1").gold > 0
  end


  test "Exploitation ticks make units bring some resources back to their territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u2", territory_id: "t5", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 0 })
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u2", deposit_id: "d5", time: 0 })
    :ok = Seelies.Router.dispatch(%Seelies.DepositsExploitationTicks{game_id: "42", time: 60 })
    {:error, :already_exploiting_deposit} = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.Game.resources(game, "t1").gold > 0
    assert Seelies.Game.resources(game, "t1").silver == 0
    assert Seelies.Game.resources(game, "t5").gold == 0
    assert Seelies.Game.resources(game, "t5").silver > 0

    :ok = Seelies.Router.dispatch(%Seelies.DepositsExploitationTicks{game_id: "42", time: 120 })
    game_2 = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.Game.resources(game_2, "t1").gold == Seelies.Game.resources(game, "t1").gold * 2
    assert Seelies.Game.resources(game_2, "t1").silver == 0
    assert Seelies.Game.resources(game_2, "t5").gold == 0
    assert Seelies.Game.resources(game_2, "t5").silver == Seelies.Game.resources(game, "t5").silver * 2
  end


  defp board() do
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
