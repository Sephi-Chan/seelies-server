defmodule Seelies.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Seelies.StartGame,
      Seelies.DeployStartingUnit,
      Seelies.UnitStartsExploitingDeposit,
      Seelies.UnitStopsExploitingDeposit,
      Seelies.DepositsExploitationTicks
    ],
    to: Seelies.Game,
    identity: :game_id
  )
end
