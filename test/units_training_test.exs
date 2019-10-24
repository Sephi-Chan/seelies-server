defmodule BaitsTests do
  use Seelies.Test.DataCase
  import Commanded.Assertions.EventAssertions


  test "Only available species can be trained" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    {:error, :unavailable_species} = Seelies.Router.dispatch(%Seelies.StartUnitTraining{game_id: "42", area_id: "a1", species: :wasp})
  end


  test "Training starts" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}]})
    :ok = Seelies.Router.dispatch(%Seelies.StartUnitTraining{game_id: "42", area_id: "a1", species: :ant})

    assert_receive_event(Seelies.UnitTrainingStarted, fn (event) ->
      assert event.game_id == "42"
      assert event.area_id == "a1"
      assert event.species == :ant
    end)
  end


  test "Spawn the unit on territory offering the best bait" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t2", quantity: %{silver: 1000, gold: 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t2", area_id: "a3", player_id: "p1", species: :beetle, resources: %{gold: 500}})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t3", quantity: %{silver: 1000, gold: 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t3", area_id: "a3", player_id: "p2", species: :beetle, resources: %{gold: 100}})
    :ok = Seelies.Router.dispatch(%Seelies.SpawnUnit{game_id: "42", area_id: "a3", unit_id: "u1", species: :beetle})

    # Now the unit is usable on the highest baiter territory.
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t2", player_id: "p1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1", player_id: "p1"})
  end
end
