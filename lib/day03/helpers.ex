defmodule Helpers.Batteries do
  def get_list_of_banks do
    "lib/day03/input.txt"
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.to_list()
  end

  def find_largest_joltage_in_bank(bank) when is_binary(bank) do
    chars =
      bank
      |> String.trim()
      |> String.to_charlist()

    if length(chars) < 2 do
      nil
    else
      # Process from right to left by reversing once
      {_, best_val} =
        chars
        |> Enum.reverse()
        |> Enum.reduce({nil, nil}, fn ch, {best_right, best_val} ->
          # ch is an integer codepoint like ?1..?9
          a = ch - ?0

          cond do
            is_nil(best_right) ->
              {a, best_val}

            true ->
              candidate = 10 * a + best_right

              new_best_val =
                case best_val do
                  nil -> candidate
                  v when candidate > v -> candidate
                  v -> v
                end

              {max(a, best_right), new_best_val}
          end
        end)

      best_val
    end
  end

  def to_str(val) when is_binary(val), do: val
  def to_str(val) when is_integer(val), do: Integer.to_string(val)
  # handles charlists like ~c"Mb"
  def to_str(val) when is_list(val), do: List.to_string(val)
  # last-resort to keep things serializable
  def to_str(val), do: inspect(val)
end
