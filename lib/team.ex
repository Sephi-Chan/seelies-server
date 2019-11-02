defmodule Seelies.Team do
  def territory_ids(game, team_id) do
    Enum.uniq(Enum.reduce(game.territories, [], fn ({territory_id, territory}, territory_ids) ->
      if territory["team"] == team_id do
        territory_ids ++ [territory_id]
      else
        territory_ids
      end
    end))
  end


  def dispatch(team_ids, territory_ids) do
    territories_count_per_team = div(length(territory_ids), length(team_ids))
    neutral_territories_count  = rem(length(territory_ids), length(team_ids))

    all_teams = Enum.reduce(team_ids, [], fn (team, all_teams) ->
      all_teams ++ List.duplicate(team, territories_count_per_team)
    end) ++ List.duplicate(nil, neutral_territories_count)

    {dispatch, _} = Enum.reduce(territory_ids, {%{}, all_teams}, fn (territory_id, {dispatch, remaining_teams}) ->
      [team|remaining_teams] = remaining_teams
      {Map.put(dispatch, territory_id, team), remaining_teams}
    end)

    dispatch
  end


  def players_from_teams(teams) do
    Enum.reduce(teams, %{}, fn (team, players) ->
      Enum.reduce(team["player_ids"], players, fn (player_id, players) ->
        Map.put(players, player_id, team["id"])
      end)
    end)
  end
end
