defmodule SeeliesTest do
  use InMemoryEventStoreCase


  test "Game can be started" do
    :ok = Seelies.Router.dispatch(%Seelies.StartGame{game_id: "42", board: board()})
  end


  def board() do
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
