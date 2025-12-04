defmodule Solve.Batteries do
  require Logger
  alias Helpers.Batteries, as: Helpers

  def run do
    joltage =
      Helpers.get_list_of_banks()
      |> Task.async_stream(
        fn bank ->
          Logger.debug("Loaded #{bank}")
          Helpers.find_largest_joltage_in_bank(bank, 12)
        end,
        timeout: :infinity
      )
      |> Enum.flat_map(fn
        {:ok, val} -> [Helpers.to_str(val)]
        {:exit, _} -> []
      end)
      |> Enum.map(fn
        s when is_binary(s) -> s |> String.trim() |> String.to_integer()
        cl when is_list(cl) -> cl |> to_string() |> String.trim() |> String.to_integer()
        n when is_integer(n) -> n
      end)

    # convert full joltage list to intgers 
    # joltage = Enum.map(joltage, &String.to_integer/1)
    # joltage

    json = Jason.encode!(joltage)
    File.write!("lib/day03/joltage.json", json)
    %{count: length(joltage), sum: Enum.sum(joltage)}
  end
end
