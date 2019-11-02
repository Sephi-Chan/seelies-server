defmodule Seelies.ResourceType do
  def decode(resource_type) when is_atom(resource_type), do: resource_type
  def decode(resource_type), do: String.to_existing_atom(resource_type)
end
