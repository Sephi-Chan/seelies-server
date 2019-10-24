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
      |> Board.add_species("a1", [:ant, :beetle])
      |> Board.add_species("a2", [:wasp])

    assert Board.area_has_species?(board, "a1", :ant)
    assert Board.area_has_species?(board, "a1", :beetle)
    refute Board.area_has_species?(board, "a1", :wasp)

    refute Board.area_has_species?(board, "a2", :ant)
    refute Board.area_has_species?(board, "a2", :beetle)
    assert Board.area_has_species?(board, "a2", :wasp)
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
end
