defmodule BaitsTests do
  use Seelies.Test.DataCase
  import Commanded.Assertions.EventAssertions


  test "Bait can't be planned on enemy territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    {:error, :unauthorized_player} = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t5", player_id: "p1", species: "ant", resources: %{"gold" => 10}, time: 10, recurrence: -1})
  end


  test "Territory must exist to plan a bait" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    {:error, :territory_not_found} = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t1000", player_id: "p1", species: "ant", resources: %{"gold" => 10}, time: 10, recurrence: -1})
  end


  test "Bait can only be planned for an existing border area/territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    {:error, :invalid_location} = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t1", area_id: "a3", player_id: "p1", species: :wasp, resources: %{"gold" => 10}, time: 10, recurrence: -1})
  end


  test "Bait can't be planned for a species that is not spawning on the territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    {:error, :unavailable_species} = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: :wasp, resources: %{"gold" => 10}, time: 10, recurrence: -1})
  end


  test "The territory doesn't need to have resources to plan the bait" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: "ant", resources: %{"gold" => 100}, time: 10, recurrence: -1})
  end


  test "The bait is set with an infinite recurrency by default" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: "ant", resources: %{"gold" => 100}, time: 10, recurrence: -1})

    assert_receive_event(Seelies.BaitPlanned, fn (event) ->
      assert event.game_id == "42"
      assert event.territory_id == "t1"
      assert event.area_id == "a1"
      assert event.resources == %{"gold" => 100}
      assert event.species == "ant"
      assert event.recurrence == 0
      assert event.time == 10
    end)

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.Bait.exists?(game, "t1", "a1", "ant")
  end


  test "The bait is replaced by a new one" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: "ant", resources: %{"gold" => 100}, time: 10, recurrence: -1})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: "ant", resources: %{"gold" => 1000}, time: 10, recurrence: -1})

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.Bait.exists?(game, "t1", "a1", "ant")
  end


  test "Bait can't be removed from an unexisting territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    {:error, :territory_not_found} = Seelies.Router.dispatch(%Seelies.RemoveBait{game_id: "42", territory_id: "t1000", player_id: "p1", species: "ant", resources: %{"gold" => 10}})
  end


  test "Can't remove a bait from an enemy territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    {:error, :unauthorized_player} = Seelies.Router.dispatch(%Seelies.RemoveBait{game_id: "42", territory_id: "t5", player_id: "p1", species: "ant"})
  end


  test "Only existing bait can be removed" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    {:error, :bait_not_found} = Seelies.Router.dispatch(%Seelies.RemoveBait{game_id: "42", territory_id: "t1", area_id: "a3000", player_id: "p1", species: "some_unknown_specie"})
  end


  test "The bait is removed" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: Seelies.Test.board(), teams: Seelies.Test.two_teams()})
    :ok = Seelies.Router.dispatch(%Seelies.PlanBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: "ant", resources: %{"gold" => 100}, time: 10, recurrence: -1})
    :ok = Seelies.Router.dispatch(%Seelies.RemoveBait{game_id: "42", territory_id: "t1", area_id: "a1", player_id: "p1", species: "ant"})

    assert_receive_event(Seelies.BaitRemoved, fn (event) ->
      assert event.game_id == "42"
      assert event.territory_id == "t1"
      assert event.area_id == "a1"
      assert event.species == "ant"
    end)

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    refute Seelies.Bait.exists?(game, "t1", "a1", "ant")
  end
end
