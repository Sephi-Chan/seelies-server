defmodule ConvoysTest do
  use InMemoryEventStoreCase
  import Commanded.Assertions.EventAssertions

  test "Convoy can't be prepared on a nonexistent territory" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    {:error, :territory_not_found} = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1000"})
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


  test "Unit can't exploit resources while in a convoy" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: SeeliesTest.board()})
    :ok = Seelies.Router.dispatch(%Seelies.DeployStartingUnit{game_id: "42", unit_id: "u1", territory_id: "t1", species: :ant})
    :ok = Seelies.Router.dispatch(%Seelies.PrepareConvoy{game_id: "42", convoy_id: "c1", territory_id: "t1"})
    :ok = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })
    {:error, :unavailable_unit} = Seelies.Router.dispatch(%Seelies.UnitJoinsConvoy{game_id: "42", convoy_id: "c1", unit_id: "u1"})
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

    {:error, :unavailable_unit} = Seelies.Router.dispatch(%Seelies.UnitStartsExploitingDeposit{game_id: "42", unit_id: "u1", deposit_id: "d1", time: 60 })
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


  test "Unit can only leave the convoy its in" do
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
end
