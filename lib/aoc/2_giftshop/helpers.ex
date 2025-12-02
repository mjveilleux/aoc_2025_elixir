defmodule Helpers.ResolveInvalidIDs do
  # parse_for_ab/1 -> {a, b}
  # Accepts "a-b" (optionally with spaces)

  def get_chunks do
    line = File.read!("lib/aoc/2_giftshop/input.txt")
    # put chunks into a list 
    chunks = line |> String.split(",", trim: true)
    chunks
  end

  def parse_for_ab(chunk) when is_binary(chunk) do
    [a, b] =
      chunk
      |> String.trim()
      |> String.split("-", parts: 2)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    {a, b}
  end

  # ab_range/2 -> a..b (inclusive)
  def ab_range(a, b) when is_integer(a) and is_integer(b) and a <= b do
    Enum.to_list(a..b)
  end

  def find_potential_candidates(raw_range_list) do
    Enum.filter(raw_range_list, fn x ->
      x
      # handle negatives safely
      |> abs()
      |> Integer.digits()
      |> length()
      |> rem(2) == 0
    end)
  end

  def count_digits(n) when is_integer(n) and n >= 0 do
    n
    |> Integer.digits()
    |> length()
  end

  def make_list_of_invalid_ids(digits)
      when is_integer(digits) and digits > 0 and rem(digits, 2) == 0 do
    k = div(digits, 2)

    min =
      if k == 1 do
        # 1..9 to avoid leading zero like 00 -> not a valid k-digit n
        1
      else
        :math.pow(10, k - 1) |> trunc()
      end

    max = trunc(:math.pow(10, k)) - 1

    pow10k = trunc(:math.pow(10, k))

    for n <- min..max do
      # duplicate the k-digit block: e.g., n=23 (k=2) -> 2323
      n * pow10k + n
    end
  end

  def evaluate_invalid_ids(candidate) do
    digits = count_digits(candidate)
    invalid_ids = make_list_of_invalid_ids(digits)

    if candidate in invalid_ids do
      candidate
    else
      nil
    end
  end

  #
  # # If you only need the sum over all invalid IDs across all chunks:
  # def sum_all(line) do
  #   evaluate_all(line)
  #   |> Enum.flat_map(fn {_a, _b, ids} -> ids end)
  #   |> Enum.sum()
  # end
end
