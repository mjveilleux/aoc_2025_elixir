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

  # this worked for part 1 but not part 2, commenting out in solver
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

  @spec is_invalid_id?(non_neg_integer()) :: boolean()
  def is_invalid_id?(n) when is_integer(n) and n >= 0 do
    s = Integer.to_string(n)
    l = String.length(s)

    # If length is 1, cannot be repetition >= 2
    if l < 2 do
      false
    else
      period_divisors(l)
      |> Enum.any?(fn k ->
        # k is the period length, repeat count r = l / k (>= 2)
        prefix = String.slice(s, 0, k)
        repeat(prefix, div(l, k)) == s
      end)
    end
  end

  defp period_divisors(l) do
    # Proper divisors k of l such that 1 <= k <= l/2 and l % k == 0
    # Iterate up to sqrt(l) for efficiency and mirror pairs.
    root = :math.sqrt(l) |> floor()

    {small, large} =
      Enum.reduce(1..root, {[], []}, fn d, {sm, lg} ->
        if rem(l, d) == 0 do
          e = div(l, d)

          sm =
            if d < l do
              [d | sm]
            else
              sm
            end

          lg =
            if e != d and e < l do
              [e | lg]
            else
              lg
            end

          {sm, lg}
        else
          {sm, lg}
        end
      end)

    # keep only k <= l/2 (repetition at least twice)
    (small ++ large)
    |> Enum.uniq()
    |> Enum.filter(&(&1 <= div(l, 2)))
    |> Enum.sort()
  end

  defp repeat(chunk, times) do
    :binary.copy(chunk, times)
  end

  @doc """
  Generate all invalid IDs of a fixed length `digits`.

  Rules:
  - IDs have exactly `digits` digits (no leading zeros in the final number).
  - Seeds (the repeating block) cannot start with '0' to avoid leading zeros in the final ID.
  - Includes all period lengths k that divide `digits` with 1 <= k <= digits/2.
  - Returns unique integers sorted ascending.
  """
  @spec generate_invalid_ids_by_length(pos_integer()) :: [non_neg_integer()]
  def generate_invalid_ids_by_length(digits)
      when is_integer(digits) and digits >= 2 do
    ks =
      period_divisors(digits)
      |> Enum.filter(&(&1 >= 1))

    ids =
      for k <- ks,
          seed <- seed_range(k),
          id_str = repeat(seed, div(digits, k)),
          # ensure no leading zero in the final number (seed[0] already ensures it)
          true do
        String.to_integer(id_str)
      end

    ids
    |> Enum.uniq()
    |> Enum.sort()
  end

  def generate_invalid_ids_by_length(_), do: []

  # Generate all k-digit seeds without leading zero
  defp seed_range(k) when k >= 1 do
    min =
      if k == 1 do
        1
      else
        :math.pow(10, k - 1) |> trunc()
      end

    max = trunc(:math.pow(10, k) - 1)

    for n <- min..max do
      Integer.to_string(n)
    end
  end

  def evaluate_invalid_ids(candidate) do
    digits = count_digits(candidate)
    invalid_ids = generate_invalid_ids_by_length(digits)

    if candidate in invalid_ids do
      candidate
    else
      nil
    end
  end
end
