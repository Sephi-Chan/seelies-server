alias Seelies.Board

defmodule BoardTest do
  use Seelies.Test.DataCase


  test "find the IDs of territories around the given area" do
    board = Board.new()
      |> Board.add_area("a1")
      |> Board.add_area("a2")
      |> Board.add_area("a3")
      |> Board.add_territory("t1", ["a1", "a2"])
      |> Board.add_territory("t2", ["a1", "a2", "a3"])

    a1_territory_ids = Board.territories_around_area(board, "a1")
    assert length(a1_territory_ids) == 2
    assert Enum.member?(a1_territory_ids, "t1")
    assert Enum.member?(a1_territory_ids, "t2")

    a2_territory_ids = Board.territories_around_area(board, "a2")
    assert length(a2_territory_ids) == 2
    assert Enum.member?(a2_territory_ids, "t1")
    assert Enum.member?(a2_territory_ids, "t2")

    a3_territory_ids = Board.territories_around_area(board, "a3")
    assert length(a3_territory_ids) == 1
    assert Enum.member?(a3_territory_ids, "t2")
  end


  test "check if the given area hosts the given species" do
    board = Board.new()
      |> Board.add_area("a1")
      |> Board.add_area("a2")
      |> Board.add_species("a1", ["ant", "beetle"])
      |> Board.add_species("a2", ["wasp"])

    assert Board.area_has_species?(board, "a1", "ant")
    assert Board.area_has_species?(board, "a1", "beetle")
    refute Board.area_has_species?(board, "a1", "wasp")

    refute Board.area_has_species?(board, "a2", "ant")
    refute Board.area_has_species?(board, "a2", "beetle")
    assert Board.area_has_species?(board, "a2", "wasp")
  end


  test "check if the given arean is around the given territory" do
    board = Board.new()
      |> Board.add_area("a1")
      |> Board.add_area("a2")
      |> Board.add_area("a3")
      |> Board.add_territory("t1", ["a1", "a2"])
      |> Board.add_territory("t2", ["a1", "a2", "a3"])

    assert Board.is_area_around_territory?(board, "a1", "t1")
    assert Board.is_area_around_territory?(board, "a2", "t1")
    refute Board.is_area_around_territory?(board, "a3", "t1")

    assert Board.is_area_around_territory?(board, "a1", "t2")
    assert Board.is_area_around_territory?(board, "a2", "t2")
    assert Board.is_area_around_territory?(board, "a3", "t2")
  end


  test "Species can be added to board" do
    Seelies.Board.new()
      |> Seelies.Board.add_area("a1")
      |> Seelies.Board.add_species("a1", ["ant", "beetle"])
  end


  test "Check if the deposit is in range of a territory" do
    board = Board.new()
      |> Board.add_area("a1")
      |> Board.add_area("a2")
      |> Board.add_area("a3")
      |> Board.add_area("a4")
      |> Board.add_deposit("a1", "d1", "gold")
      |> Board.add_deposit("a1", "d2", "silver")
      |> Board.add_deposit("a2", "d3", "gold")
      |> Board.add_deposit("a3", "d4", "gold")
      |> Board.add_deposit("a4", "d5", "silver")
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

      assert Seelies.Board.is_deposit_in_range?(board, "d1", "t1")
      refute Seelies.Board.is_deposit_in_range?(board, "d5", "t1")
  end
end
