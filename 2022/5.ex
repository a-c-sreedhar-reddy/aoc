defmodule Crane do
  defp move_one_crate([top | from], to) do
    {from, [top | to]}
  end

  def move_crates(from, to, n) do
    case n do
      0 ->
        {from, to}

      _ ->
        {from, to} = move_one_crate(from, to)
        move_crates(from, to, n - 1)
    end
  end

  def move_crates_in_order(from, to, n) do
    {moving_crates, from} = Enum.split(from, n)
    {from, moving_crates ++ to}
  end

  def get_top_crates(crates) do
    crates
    |> Enum.filter(fn crate -> length(crate) != 0 end)
    |> Enum.map(fn crate -> hd(crate) end)
  end
end

crates = [
  ["W", "L", "S"],
  ["Q", "N", "T", "J"],
  ["J", "F", "H", "C", "S"],
  ["B", "G", "N", "W", "M", "R", "T"],
  ["B", "Q", "H", "D", "S", "L", "R", "T"],
  ["L", "R", "H", "F", "V", "B", "J", "M"],
  ["M", "J", "N", "R", "W", "D"],
  ["J", "D", "N", "H", "F", "T", "Z", "B"],
  ["T", "F", "B", "N", "Q", "L", "H"]
]

moves =
  File.read!("./data/5.txt")
  |> String.split("\n\n")
  |> then(fn [_, tl] -> tl end)
  |> String.split("\n")
  |> Enum.map(fn line ->
    values = String.split(line, " ")
    {n, _} = values |> Enum.at(1) |> Integer.parse()
    {from, _} = values |> Enum.at(3) |> Integer.parse()
    {to, _} = values |> Enum.at(5) |> Integer.parse()
    [from, to, n]
  end)

moves
|> List.foldl(crates, fn [from, to, n], crates ->
  from_index = from - 1
  to_index = to - 1
  from_crate = Enum.at(crates, from_index)
  to_crate = Enum.at(crates, to_index)
  {new_from_crate, new_to_crate} = Crane.move_crates(from_crate, to_crate, n)

  crates
  |> Enum.with_index(fn crate, index ->
    case index do
      ^from_index -> new_from_crate
      ^to_index -> new_to_crate
      _ -> crate
    end
  end)
end)
|> Crane.get_top_crates()
|> IO.puts()

moves
|> List.foldl(crates, fn [from, to, n], crates ->
  from_index = from - 1
  to_index = to - 1
  from_crate = Enum.at(crates, from_index)
  to_crate = Enum.at(crates, to_index)
  {new_from_crate, new_to_crate} = Crane.move_crates_in_order(from_crate, to_crate, n)

  crates
  |> Enum.with_index(fn crate, index ->
    case index do
      ^from_index -> new_from_crate
      ^to_index -> new_to_crate
      _ -> crate
    end
  end)
end)
|> Crane.get_top_crates()
|> IO.puts()
