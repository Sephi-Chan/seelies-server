defmodule BaitsTests do
  use Seelies.Test.DataCase
  import Commanded.Assertions.EventAssertions


  test "Only available species can be trained" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    {:error, :unavailable_species} = Seelies.Router.dispatch(%Seelies.StartUnitTraining{game_id: "42", area_id: "a1", species: :wasp})
  end


  test "Training starts" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.one_team()})
    :ok = Seelies.Router.dispatch(%Seelies.StartUnitTraining{game_id: "42", area_id: "a1", species: "ant"})

    assert_receive_event(Seelies.UnitTrainingStarted, fn (event) ->
      assert event.game_id == "42"
      assert event.area_id == "a1"
      assert event.species == "ant"
    end)
  end


  test "Spawn the unit on territory offering the best bait and consume the resources" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t2", quantity: %{"silver" => 1000, "gold" => 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t2", area_id: "a3", player_id: "p1", species: "beetle", recurrence: -1, time: 10, resources: %{"gold" => 500}})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t3", quantity: %{"silver" => 1000, "gold" => 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t3", area_id: "a3", player_id: "p2", species: "beetle", recurrence: -1, time: 10, resources: %{"gold" => 100}})
    :ok = Seelies.Router.dispatch(%Seelies.SpawnUnit{game_id: "42", area_id: "a3", unit_id: "u1", species: "beetle"})

    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t2", player_id: "p1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1", player_id: "p1"})
    {:error, :not_enough_resources} = Seelies.Router.dispatch(%Seelies.LoadResourcesIntoConvoy{game_id: "42", convoy_id: "c1", resources: %{"gold" => 1000}, player_id: "p1"})
  end


  test "Spawn the first two units on the best baiter then on the other baiter when the recurrence runs out" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t2", quantity: %{"silver" => 1000, "gold" => 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t2", area_id: "a3", player_id: "p1", species: "beetle", recurrence: 2, time: 10, resources: %{"gold" => 200}})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t3", quantity: %{"silver" => 1000, "gold" => 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t3", area_id: "a3", player_id: "p2", species: "beetle", recurrence: -1, time: 10, resources: %{"gold" => 100}})

    :ok = Seelies.Router.dispatch(%Seelies.SpawnUnit{game_id: "42", area_id: "a3", unit_id: "u1", species: "beetle"})
    :ok = Seelies.Router.dispatch(%Seelies.SpawnUnit{game_id: "42", area_id: "a3", unit_id: "u2", species: "beetle"})
    :ok = Seelies.Router.dispatch(%Seelies.SpawnUnit{game_id: "42", area_id: "a3", unit_id: "u3", species: "beetle"})

    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t2", player_id: "p1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1", player_id: "p1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u2", player_id: "p1"})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c2", territory_id: "t3", player_id: "p2"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c2", unit_id: "u3", player_id: "p2"})
  end


  test "Unit disappears since there is no bait" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.SpawnUnit{game_id: "42", area_id: "a3", unit_id: "u1", species: "beetle"})

    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t2", player_id: "p1"})
    {:error, :unit_not_found} = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1", player_id: "p1"})
  end


  test "Spawn the unit on territory offering the worst bait since the best baiter can't honor its bait" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t2", area_id: "a3", player_id: "p1", species: "beetle", recurrence: -1, time: 10, resources: %{"gold" => 500}})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t3", quantity: %{"silver" => 1000, "gold" => 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t3", area_id: "a3", player_id: "p2", species: "beetle", recurrence: -1, time: 20, resources: %{"gold" => 100}})
    :ok = Seelies.Router.dispatch(%Seelies.SpawnUnit{game_id: "42", area_id: "a3", unit_id: "u1", species: "beetle"})

    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t3", player_id: "p2"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1", player_id: "p2"})
  end


  test "Unit disappears since no baiter can honor its bait" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t2", area_id: "a3", player_id: "p1", species: "beetle", recurrence: -1, time: 10, resources: %{"gold" => 500}})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t3", area_id: "a3", player_id: "p2", species: "beetle", recurrence: -1, time: 20, resources: %{"gold" => 100}})
    :ok = Seelies.Router.dispatch(%Seelies.SpawnUnit{game_id: "42", area_id: "a3", unit_id: "u1", species: "beetle"})

    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t2", player_id: "p1"})
    {:error, :unit_not_found} = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1", player_id: "p1"})
  end


  test "Spawn the unit on the oldest bait since they both offer the same bait" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t2", quantity: %{"silver" => 1000, "gold" => 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t2", area_id: "a3", player_id: "p1", species: "beetle", recurrence: -1, time: 20, resources: %{"gold" => 100}})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t3", quantity: %{"silver" => 1000, "gold" => 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t3", area_id: "a3", player_id: "p2", species: "beetle", recurrence: -1, time: 10, resources: %{"gold" => 100}})
    :ok = Seelies.Router.dispatch(%Seelies.SpawnUnit{game_id: "42", area_id: "a3", unit_id: "u1", species: "beetle"})

    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t3", player_id: "p2"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1", player_id: "p2"})
  end
end
