defmodule UnitsSpawingTest do
  use Seelies.Test.DataCase


  test "Species can be added to board" do
    Seelies.Board.new()
      |> Seelies.Board.add_area("a1")
      |> Seelies.Board.add_species("a1", [:ant, :beetle])
  end
end
