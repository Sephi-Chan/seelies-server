require Seelies.Game
require Seelies.GameLifespan

defmodule Seelies.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Seelies.StartGame,
      Seelies.StopGame,
      Seelies.AddResources,
      Seelies.DeployStartingUnit,
      Seelies.UnitStartsExploitingDeposit,
      Seelies.UnitStopsExploitingDeposit,
      Seelies.DepositsExploitationTicks,
      Seelies.PrepareConvoy,
      Seelies.UnitJoinsConvoy,
      Seelies.UnitLeavesConvoy,
      Seelies.LoadResourcesIntoConvoy,
      Seelies.UnloadResourcesFromConvoy,
      Seelies.ConvoyStarts,
      Seelies.ConvoyReachesDestination,
      Seelies.DisbandConvoy,
      Seelies.DeployBait,
      Seelies.RemoveBait,
    ],
    to: Seelies.Game,
    identity: :game_id,
    lifespan: Seelies.GameLifespan
  )
end
