defmodule TeamTest do
  use Seelies.Test.DataCase


  test "Dispatch the same number of territories to each team, remaining ones are neutral" do
    dispatch = Seelies.Team.dispatch([:red, :blue], ["t1", "t2", "t3", "t4", "t5"])

    assert dispatch["t1"] == :red
    assert dispatch["t2"] == :red
    assert dispatch["t3"] == :blue
    assert dispatch["t4"] == :blue
    assert dispatch["t5"] == nil
  end


  test "Dispatch the same number of territories to each team, remaining ones are neutral bis" do
    dispatch = Seelies.Team.dispatch([:red, :blue, :green], ["t1", "t2", "t3", "t4", "t5"])

    assert dispatch["t1"] == :red
    assert dispatch["t2"] == :blue
    assert dispatch["t3"] == :green
    assert dispatch["t4"] == nil
    assert dispatch["t5"] == nil
  end



  test "Build players structure from teams list" do
    teams   = [%{id: "red", player_ids: ["p1"]}, %{id: "blue", player_ids: ["p2", "p3"]}]
    players = Seelies.Team.players_from_teams(teams)

    assert players["p1"] == "red"
    assert players["p2"] == "blue"
    assert players["p3"] == "blue"
  end
end
