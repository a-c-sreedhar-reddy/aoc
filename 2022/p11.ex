defmodule MathFunctions do
  def lcm(a, b) when a == 0 or b == 0, do: 0
  def lcm(a, b), do: floor(abs(a * b) / gcd(a, b))

  defp gcd(a, 0), do: a
  defp gcd(a, b), do: gcd(b, rem(a, b))
end

defmodule MonkeyGame do
  def parse_monkey(monkey) do
    monkey = monkey |> String.split("\n")
    "  Starting items: " <> items_string = Enum.at(monkey, 1)
    items = items_string |> String.split(", ") |> Enum.map(fn item -> String.to_integer(item) end)
    operation_string = Enum.at(monkey, 2)

    operation =
      case operation_string do
        "  Operation: new = old * old" ->
          fn i -> i * i end

        "  Operation: new = old + " <> value ->
          fn i -> i + String.to_integer(value) end

        "  Operation: new = old * " <> value ->
          fn i -> i * String.to_integer(value) end
      end

    "  Test: divisible by " <> divisor_string = Enum.at(monkey, 3)
    divisor = String.to_integer(divisor_string)
    "    If true: throw to monkey " <> true_monkey_string = Enum.at(monkey, 4)
    true_monkey = String.to_integer(true_monkey_string)
    "    If false: throw to monkey " <> false_monkey_string = Enum.at(monkey, 5)
    false_monkey = String.to_integer(false_monkey_string)

    %{
      items: items,
      update_worry_level: operation,
      get_pass_monkey_index: &if(rem(&1, divisor) == 0, do: true_monkey, else: false_monkey),
      inspect_count: 0,
      divisor: divisor
    }
  end

  def play(monkeys, rounds, reduce_stress) do
    1..rounds
    |> Enum.reduce(monkeys, fn _, monkeys ->
      play_round(monkeys, reduce_stress)
    end)
  end

  def play_round(monkeys, reduce_stress) do
    1..length(monkeys)
    |> Enum.reduce(monkeys, fn index, monkeys ->
      index = index - 1
      monkeys |> play_monkey(index, reduce_stress)
    end)
  end

  def play_monkey(monkeys, index, reduce_stress) do
    monkey = Enum.at(monkeys, index)
    items = monkey.items
    monkey = %{monkey | items: [], inspect_count: monkey.inspect_count + length(items)}
    monkeys = List.update_at(monkeys, index, fn _ -> monkey end)

    items
    |> Enum.reduce(monkeys, fn item, monkeys ->
      play_monkey_item(monkeys, monkey, item, reduce_stress)
    end)
  end

  def play_monkey_item(monkeys, monkey, item, reduce_stress) do
    worry_level = reduce_stress.(monkey.update_worry_level.(item))
    pass_monkey_index = monkey.get_pass_monkey_index.(worry_level)

    List.update_at(monkeys, pass_monkey_index, fn monkey ->
      %{monkey | items: [worry_level | monkey.items]}
    end)
  end
end

initial_monkeys =
  File.read!("data/11.txt")
  |> String.split("\n\n")
  |> Enum.map(&MonkeyGame.parse_monkey/1)

monkeys = MonkeyGame.play(initial_monkeys, 20, fn stress -> Integer.floor_div(stress, 3) end)

[first | [second | _]] =
  monkeys |> Enum.map(fn monkey -> monkey.inspect_count end) |> Enum.sort(:desc)

IO.inspect(first * second)

lcm =
  initial_monkeys
  |> Enum.map(fn monkey -> monkey.divisor end)
  |> Enum.reduce(1, fn divisor, lcm -> MathFunctions.lcm(lcm, divisor) end)

monkeys = MonkeyGame.play(initial_monkeys, 10000, fn stress -> rem(stress, lcm) end)

[first | [second | _]] =
  monkeys |> Enum.map(fn monkey -> monkey.inspect_count end) |> Enum.sort(:desc)

IO.inspect(first * second)
