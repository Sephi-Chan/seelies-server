defmodule ConvoysTest do
  use InMemoryEventStoreCase
  import Commanded.Assertions.EventAssertions

  test "Convoy can't be prepared on a nonexistent territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    {:error, :territory_not_found} = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1000"})
  end


  test "Convoy ID must be unique" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    {:error, :convoy_already_exists} = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
  end


  test "Convoy is prepared on a territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u2", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})

    assert_receive_event(Seelies.ConvoyReadied, fn (event) ->
      assert event.game_id == "42"
      assert event.convoy_id == "c1"
      assert event.territory_id == "t1"
    end)
  end


  test "Unit can't join a nonexistent convoy" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    {:error, :convoy_not_found} = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1000", unit_id: "u1"})
  end


  test "Nonexistent unit can't join a convoy" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    {:error, :unit_not_found} = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1000"})
  end


  test "Unit can't join a convoy twice" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
    {:error, :already_joined} =  Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
  end


  test "Unit can't join convoy while exploiting" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })
    {:error, :busy_exploiting} = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
  end


  test "Unit can't join a convoy from another territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t2"})
    {:error, :convoy_too_far} = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
  end


  test "Unit joins the convoy and is no longer available for exploitation" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})

    assert_receive_event(Seelies.UnitJoinedConvoy, fn (event) ->
      assert event.game_id == "42"
      assert event.convoy_id == "c1"
      assert event.unit_id == "u1"
    end)

    {:error, :busy_convoying} = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })
  end


  test "Nonexistent unit can't leave the convoy" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    {:error, :unit_not_found} = Seelies.Router.dispatch(%Seelies.UnitLeavesConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1000"})
  end


  test "Unit can't leave a nonexistent convoy" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    {:error, :convoy_not_found} = Seelies.Router.dispatch(%Seelies.UnitLeavesConvoy{game_id: "42", convoy_id: "c1000", unit_id: "u1"})
  end


  test "Unit can only leave the convoy if it belongs to it" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    {:error, :not_in_convoy} = Seelies.Router.dispatch(%Seelies.UnitLeavesConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
  end


  test "Unit leaves the convoy and becomes available again" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitLeavesConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})

    assert_receive_event(Seelies.UnitLeftConvoy, fn (event) ->
      assert event.game_id == "42"
      assert event.convoy_id == "c1"
      assert event.unit_id == "u1"
    end)

    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })
  end


  test "Nonexistent convoy can't be loaded with resources" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    {:error, :convoy_not_found} = Seelies.Router.dispatch(%Seelies.LoadResourcesIntoConvoy{game_id: "42", convoy_id: "c1000", resources: %{silver: 500, gold: 100}})
  end


  test "Convoy can't be loaded if resources are missing" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    {:error, :not_enough_resources} = Seelies.Router.dispatch(%Seelies.LoadResourcesIntoConvoy{game_id: "42", convoy_id: "c1", resources: %{silver: 500, gold: 100}})
  end


  test "Loaded resources are moved from the territory to the convoy" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{silver: 1000, gold: 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.LoadResourcesIntoConvoy{game_id: "42", convoy_id: "c1", resources: %{silver: 500, gold: 100}})

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.ResourcesQuantity.territory(game, "t1").silver == 500
    assert Seelies.ResourcesQuantity.territory(game, "t1").gold == 900
    assert Seelies.ResourcesQuantity.convoy(game, "c1").silver == 500
    assert Seelies.ResourcesQuantity.convoy(game, "c1").gold == 100
  end


  test "Nonexistent convoy can't be unloaded" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    {:error, :convoy_not_found} = Seelies.Router.dispatch(%Seelies.UnloadResourcesFromConvoy{game_id: "42", convoy_id: "c1000", resources: %{silver: 500, gold: 100}})
  end


  test "Only loaded resources can be unloaded from the convoy" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    {:error, :not_enough_resources} = Seelies.Router.dispatch(%Seelies.UnloadResourcesFromConvoy{game_id: "42", convoy_id: "c1", resources: %{silver: 500, gold: 100}})
  end


  test "Unloaded resources are moved from the convoy to the territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{silver: 1000, gold: 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.LoadResourcesIntoConvoy{game_id: "42", convoy_id: "c1", resources: %{silver: 500, gold: 500}})
    :ok = Seelies.Router.dispatch(%Seelies.UnloadResourcesFromConvoy{game_id: "42", convoy_id: "c1", resources: %{gold: 250}})

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.ResourcesQuantity.territory(game, "t1").silver == 500
    assert Seelies.ResourcesQuantity.territory(game, "t1").gold == 750
    assert Seelies.ResourcesQuantity.convoy(game, "c1").silver == 500
    assert Seelies.ResourcesQuantity.convoy(game, "c1").gold == 250
  end


  test "Nonexistent convoy can't start" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    {:error, :convoy_not_found} = Seelies.Router.dispatch(%Seelies.ConvoyStarts{game_id: "42", convoy_id: "c1000", destination_territory_id: "t2"})
  end


  test "Convoy need at least one unit to start" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    {:error, :no_unit} = Seelies.Router.dispatch(%Seelies.ConvoyStarts{game_id: "42", convoy_id: "c1", destination_territory_id: "t2"})
  end


  test "Convoy can't go to nonexistent territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
    {:error, :territory_not_found} = Seelies.Router.dispatch(%Seelies.ConvoyStarts{game_id: "42", convoy_id: "c1", destination_territory_id: "t1000"})
  end


  test "Convoy can only start to neighbour territories" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
    {:error, :territory_too_far} = Seelies.Router.dispatch(%Seelies.ConvoyStarts{game_id: "42", convoy_id: "c1", destination_territory_id: "t4"})
  end


  test "Convoy starts at the speed of its slowest unit and can't be started anymore" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u2", territory_id: "t1", species: :beetle})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u2"})
    :ok = Seelies.Router.dispatch(%Seelies.ConvoyStarts{game_id: "42", convoy_id: "c1", destination_territory_id: "t2"})

    assert_receive_event(Seelies.ConvoyStarted, fn (event) ->
      assert event.game_id == "42"
      assert event.convoy_id == "c1"
      assert event.duration == 4629 # duration = 9 metres * 3600 seconds / 7 metres per hour
    end)

    {:error, :already_started} = Seelies.Router.dispatch(%Seelies.ConvoyStarts{game_id: "42", convoy_id: "c1", destination_territory_id: "t2"})
  end


  test "Convoy is unloaded upon arrival and convoy is disbanded" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{silver: 1000, gold: 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.LoadResourcesIntoConvoy{game_id: "42", convoy_id: "c1", resources: %{silver: 500, gold: 500}})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
    :ok = Seelies.Router.dispatch(%Seelies.ConvoyStarts{game_id: "42", convoy_id: "c1", destination_territory_id: "t2"})
    :ok = Seelies.Router.dispatch(%Seelies.ConvoyReachesDestination{game_id: "42", convoy_id: "c1"})

    assert_receive_event(Seelies.ConvoyReachedDestination, fn (event) ->
      assert event.game_id == "42"
      assert event.convoy_id == "c1"
    end)

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.ResourcesQuantity.territory(game, "t2").silver == 500
    assert Seelies.ResourcesQuantity.territory(game, "t2").gold == 500

    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t2"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d4", time: 60 })
  end


  test "Nonexistent convoy can't be disbanded" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    {:error, :convoy_not_found} = Seelies.Router.dispatch(%Seelies.DisbandConvoy{game_id: "42", convoy_id: "c1"})
  end


  test "Departed convoys can't be disbanded" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{silver: 1000, gold: 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.LoadResourcesIntoConvoy{game_id: "42", convoy_id: "c1", resources: %{silver: 500, gold: 500}})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
    :ok = Seelies.Router.dispatch(%Seelies.ConvoyStarts{game_id: "42", convoy_id: "c1", destination_territory_id: "t2"})
    {:error, :already_started} = Seelies.Router.dispatch(%Seelies.DisbandConvoy{game_id: "42", convoy_id: "c1"})
  end


  test "Resources of a disbanded are unloaded and units are returned" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.AddResources{game_id: "42", territory_id: "t1", quantity: %{silver: 1000, gold: 1000}})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.LoadResourcesIntoConvoy{game_id: "42", convoy_id: "c1", resources: %{silver: 500, gold: 500}})
    :ok = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
    :ok = Seelies.Router.dispatch(%Seelies.DisbandConvoy{game_id: "42", convoy_id: "c1"})

    game = Commanded.Aggregates.Aggregate.aggregate_state(Seelies.Game, "42")
    assert Seelies.ResourcesQuantity.territory(game, "t1").silver == 1000
    assert Seelies.ResourcesQuantity.territory(game, "t1").gold == 1000

    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t2"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })
  end
end
