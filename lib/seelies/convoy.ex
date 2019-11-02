defmodule Seelies.Convoy do
  def exists?(%Seelies.Game{convoys: convoys}, convoy_id) do
    convoys[convoy_id] != nil
  end


  def is_near_unit?(%Seelies.Game{convoys: convoys, units: units}, convoy_id, unit_id) do
    convoy_territory_id = convoys[convoy_id]["territory_id"]
    unit_territory_id   = units[unit_id]["territory_id"]

    convoy_territory_id == unit_territory_id
  end


  def has_unit?(%Seelies.Game{convoys: convoys}, convoy_id) do
    Enum.any?(convoys[convoy_id]["unit_ids"])
  end


  def started?(%Seelies.Game{convoys: convoys}, convoy_id) do
    convoys[convoy_id]["destination_territory_id"] != nil
  end
end
