defmodule Seelies.Game do
  defstruct [:game_id, :board, :units, :exploitations, :territories, :convoys, :teams, :players]


  def execute(game, command) do
    command.__struct__.execute(game, command)
  end


  def apply(game, event) do
    event.__struct__.apply(game, event)
  end
end


defmodule Seelies.GameLifespan do
  def after_event(%Seelies.GameStopped{}), do: :stop
  def after_event(_event), do: :infinity
  def after_command(_command), do: :infinity
  def after_error(_error), do: :infinity
end
