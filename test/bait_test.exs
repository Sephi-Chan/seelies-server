defmodule BaitTest do
  use Seelies.Test.DataCase


  test "no territory is returned since there is no bait" do
    assert Seelies.Bait.find_highest_baiter_territory([], %{}) == nil
  end


  test "return the highest bidder territory" do
    assert Seelies.Bait.find_highest_baiter_territory([
      {%{gold: 100, silver: 100}, 10, "t1"},
      {%{gold: 500, silver: 500}, 10, "t2"}
    ], %{}) == {%{gold: 500, silver: 500}, 10, "t2"}
  end


  test "return the unique baiter" do
    assert Seelies.Bait.find_highest_baiter_territory([{%{gold: 100}, 10, "t1"}], %{}) == {%{gold: 100}, 10, "t1"}
  end


  test "return the oldest bait when baits are the same" do
    assert Seelies.Bait.find_highest_baiter_territory([
      {%{gold: 100, silver: 100}, 10, "t1"},
      {%{gold: 100, silver: 100}, 20, "t2"}
    ], %{}) == {%{gold: 100, silver: 100}, 10, "t1"}
  end


  test "Species preferences matters" do
    assert Seelies.Bait.find_highest_baiter_territory([
      {%{gold: 100, silver: 100}, 10, "t1"},
      {%{gold: 500, silver: 0}, 10, "t2"}
    ], %{silver: 10}) == {%{gold: 100, silver: 100}, 10, "t1"}
  end
end
