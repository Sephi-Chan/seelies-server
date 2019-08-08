defmodule UnitsDeploymentTest do
  use Seelies.Test.DataCase
  import Commanded.Assertions.EventAssertions


  test "Unit can't be deployed on a nonexistent territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}]})
    {:error, :territory_not_found} = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1000", species: :ant})
  end


  test "Unit ID must be unique" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}]})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "endive", territory_id: "t1", species: :ant})
    {:error, :unit_already_exists} = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "endive", territory_id: "t1", species: :ant})
  end


  test "Deploys a starting unit to a territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}]})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})

    assert_receive_event(Seelies.StartingUnitDeployed, fn (event) ->
      assert event.game_id == "42"
      assert event.unit_id == "u1"
      assert event.territory_id == "t1"
      assert event.species == "ant"
    end)
  end
end
