defmodule Aoc2025Elixir.Aoc do
  def initialize_lock do
    # create sequence from 0-99 and concat that sequence 100 times
    sequence = Enum.to_list(0..99)
    concatenated_sequence = Enum.concat(List.duplicate(sequence, 100))
    # add a column for position number
    positioned_sequence =
      Enum.with_index(concatenated_sequence, fn value, index -> {index, value} end)

    # table: key - value where key is the position and the value is the concatenated_sequence

    positioned_sequence
  end

  def find_middle_50_of_lock_sequence do
    lock = initialize_lock()
    fifties = Enum.filter(lock, fn {_, val} -> val == 50 end)

    case length(fifties) do
      0 ->
        # Handle the case where no 50s exist
        nil

      len ->
        middle_index = div(len - 1, 2)
        # Fix: Match the 2-element tuple {pos, _}
        {pos, _} = Enum.at(fifties, middle_index)
        pos
    end
  end

  def get_net_steps do
    # get the file documents/day1.txt 
    # read line by line 
    # if starts with R then positive 
    # if starts with L then negative

    read_file = File.read!("lib/aoc/documents/day1.txt")

    # return list of lines 

    read_file
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      num = String.slice(line, 1..-1//1) |> String.to_integer()

      case String.at(line, 0) do
        "R" -> num
        "L" -> -num
      end
    end)
    |> Enum.sum()
  end

  def get_final_position_and_lock_value do
    lock = initialize_lock()
    initial_pos = find_middle_50_of_lock_sequence()
    net_steps = get_net_steps()

    final_pos = Enum.sum([initial_pos, net_steps])

    answer = Enum.filter(lock, fn {pos, _} -> pos == final_pos end)
    answer
  end
end

defmodule Aoc2025Elixir.SolveDay1 do
  def run do
    # get all 50s in this lock
    # Aoc2025Elixir.Aoc.initialize_lock()
    # Aoc2025Elixir.Aoc.find_middle_50_of_lock_sequence()
    # Aoc2025Elixir.Aoc.find_middle_50_of_lock_sequence()
    # Aoc2025Elixir.Aoc.get_and_transcribe_documents()
    Aoc2025Elixir.Aoc.get_final_position_and_lock_value()
  end
end
