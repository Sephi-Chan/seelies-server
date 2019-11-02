defmodule Seelies.Player do
  def can_control_unit?(%Seelies.Game{players: players, units: units, territories: territories}, player_id, unit_id) do
    player_team    = players[player_id]
    territory_id   = units[unit_id]["territory_id"]
    territory_team = territories[territory_id]["team"]

    player_team == territory_team
  end


  def can_manage_territory?(%Seelies.Game{players: players, territories: territories}, player_id, territory_id) do
    player_team    = players[player_id]
    territory_team = territories[territory_id]["team"]

    player_team == territory_team
  end


  def can_manage_convoy?(%Seelies.Game{players: players, convoys: convoys, territories: territories}, player_id, convoy_id) do
    player_team    = players[player_id]
    territory_id   = convoys[convoy_id]["territory_id"]
    territory_team = territories[territory_id]["team"]

    player_team == territory_team
  end
end
