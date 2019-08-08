defmodule Seelies.JsonSerializer do
  alias Commanded.EventStore.TypeProvider
  alias Commanded.Serialization.JsonDecoder


  def serialize(term) do
    Jason.encode!(term)
  end


  def deserialize(binary, config \\ []) do
    {type, opts} =
      case Keyword.get(config, :type) do
        nil -> {nil, %{}}
        type -> {TypeProvider.to_struct(type), %{}}
      end

    binary
    |> Jason.decode!(opts)
    |> to_struct(type)
    |> JsonDecoder.decode()
  end

  defp to_struct(data, nil), do: data
  defp to_struct(data, struct), do: struct(struct, data)
end
