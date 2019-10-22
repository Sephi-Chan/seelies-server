defmodule BaitsTests do
  use Seelies.Test.DataCase
  import Commanded.Assertions.EventAssertions


  test "Bait can't be set on enemy territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    {:error, :unauthorized_player} = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t5", player_id: "p1", species: :ant, resources: %{gold: 10}})
  end


  test "Territory must exist to set a bait" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    {:error, :territory_not_found} = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1000", player_id: "p1", species: :ant, resources: %{gold: 10}})
  end


  test "Bait can only be set for an existing border area/territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    {:error, :invalid_location} = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1", area_id: "a3", player_id: "p1", species: :wasp, resources: %{gold: 10}})
  end


  test "Bait can't be set for a species that is not spawning on the territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    {:error, :unavailable_species} = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :wasp, resources: %{gold: 10}})
  end


  test "The territory must have enough resources to set the bait" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    {:error, :not_enough_resources} = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :ant, resources: %{gold: 100}})
  end


  test "The bait is set" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{gold: 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :ant, resources: %{gold: 100}})

    assert_receive_event(Seelies.BaitDeployed, fn (event) ->
      assert event.game_id == "42"
      assert event.territory_id == "t1"
      assert event.area_id == "a1"
      assert event.resources == %{gold: 100}
      assert event.species == :ant
    end)

    {:error, :not_enough_resources} = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :beetle, resources: %{gold: 1000}})
  end


  test "The bait can't be set twice" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{gold: 1000, silver: 400}})
    :ok = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :ant, resources: %{gold: 100}})
    {:error, :bait_already_set} = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :ant, resources: %{gold: 100}})
  end


  test "Bait can't be removed from an unexisting territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    {:error, :territory_not_found} = Seelies.Router.dispatch(%Seelies.RemoveBait{game_id: "42", territory_id: "t1000", player_id: "p1", species: :ant, resources: %{gold: 10}})
  end


  test "Can't remove a bait from an enemy territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    {:error, :unauthorized_player} = Seelies.Router.dispatch(%Seelies.RemoveBait{game_id: "42", territory_id: "t5", player_id: "p1", species: :ant})
  end


  test "Only existing bait can be removed" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    {:error, :bait_not_found} = Seelies.Router.dispatch(%Seelies.RemoveBait{game_id: "42", territory_id: "t1", area_id: "a3000", player_id: "p1", species: :some_unknown_specie})
  end


  test "The bait is removed" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2"]}]})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{gold: 1000, silver: 400}})
    :ok = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :ant, resources: %{gold: 100}})
    :ok = Seelies.Router.dispatch(%Seelies.RemoveBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :ant})

    assert_receive_event(Seelies.BaitRemoved, fn (event) ->
      assert event.game_id == "42"
      assert event.territory_id == "t1"
      assert event.area_id == "a1"
      assert event.species == :ant
    end)

    :ok = Seelies.Router.dispatch(%Seelies.DeployBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :ant, resources: %{gold: 1000}})
  end
end
