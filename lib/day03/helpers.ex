defmodule Helpers.Batteries do
  def get_list_of_banks do
    "lib/day03/input.txt"
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.to_list()
  end

  # this solves the first one
  # def find_largest_joltage_in_bank(bank) when is_binary(bank) do
  #   chars =
  #     bank
  #     |> String.trim()
  #     |> String.to_charlist()
  #
  #   if length(chars) < 2 do
  #     nil
  #   else
  #     # Process from right to left by reversing once
  #     {_, best_val} =
  #       chars
  #       |> Enum.reverse()
  #       |> Enum.reduce({nil, nil}, fn ch, {best_right, best_val} ->
  #         # ch is an integer codepoint like ?1..?9
  #         a = ch - ?0
  #
  #         cond do
  #           is_nil(best_right) ->
  #             {a, best_val}
  #
  #           true ->
  #             candidate = 10 * a + best_right
  #
  #             new_best_val =
  #               case best_val do
  #                 nil -> candidate
  #                 v when candidate > v -> candidate
  #                 v -> v
  #               end
  #
  #             {max(a, best_right), new_best_val}
  #         end
  #       end)
  #
  #     best_val
  #   end
  # end

  def find_largest_joltage_in_bank(bank, k) when is_binary(bank) and is_integer(k) and k >= 1 do
    chars =
      bank
      |> String.trim()
      |> String.to_charlist()

    n = length(chars)
    if n < k, do: nil, else: do_find(chars, k)
  end

  defp do_find(chars, k) do
    # Precompute powers of 10 up to k for fast concatenation
    pow10 =
      0..k
      |> Enum.map(fn e -> :math.pow(10, e) |> trunc() end)
      |> List.to_tuple()

    # dp[j] = best j-digit number (integer) from processed suffix; j in 0..k
    # dp[0] = 0 (empty number); dp[j>0] = nil initially
    init_dp =
      0..k
      |> Enum.map(fn
        0 -> 0
        _ -> nil
      end)
      |> :array.from_list()

    # Track best single digit so far (for j=1) to avoid scanning dp[1] every time
    {final_dp, _best1} =
      chars
      |> Enum.reverse()
      |> Enum.reduce({init_dp, nil}, fn ch, {dp, best1} ->
        d = ch - ?0

        # Update dp from j=k down to 1
        dp_updated =
          Enum.reduce(k..1, dp, fn j, acc ->
            prev = :array.get(j - 1, acc)
            cur = :array.get(j, acc)

            new_val =
              cond do
                is_nil(prev) ->
                  cur

                j == 1 ->
                  # For j=1, prev = 0; just take best single digit
                  case cur do
                    nil -> d
                    v when d > v -> d
                    v -> v
                  end

                true ->
                  # concatenate d as most significant digit to best (j-1)-digit number
                  candidate = d * elem(pow10, j - 1) + prev

                  case cur do
                    nil -> candidate
                    v when candidate > v -> candidate
                    v -> v
                  end
              end

            :array.set(j, new_val, acc)
          end)

        # Maintain best1 (optional; dp update already handled it)
        best1_new =
          case best1 do
            nil -> d
            v when d > v -> d
            v -> v
          end

        {dp_updated, best1_new}
      end)

    result = :array.get(k, final_dp)
    # Ensure exactly k digits (leading zeros forbidden). If you want to allow
    # leading zeros, remove this guard.
    case result do
      nil ->
        nil

      v ->
        # Check digit count without converting to string
        min_k = :math.pow(10, k - 1) |> trunc()
        if k == 1 or v >= min_k, do: v, else: nil
    end
  end

  def to_str(val) when is_binary(val), do: val
  def to_str(val) when is_integer(val), do: Integer.to_string(val)
  # handles charlists like ~c"Mb"
  def to_str(val) when is_list(val), do: List.to_string(val)
  # last-resort to keep things serializable
  def to_str(val), do: inspect(val)
end
