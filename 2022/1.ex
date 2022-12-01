{max, totalmax} =
  File.read!("./data/1.txt")
  |> String.split("\n")
  |> List.foldl({[], 0}, fn x, {energies, currentEnergy} ->
    case x do
      "" -> {[currentEnergy | energies], 0}
      _ -> {energies, currentEnergy + String.to_integer(x)}
    end
  end)
  |> then(fn {energies, _} ->
    [first | [second | [third | _]]] = Enum.sort(energies, :desc)
    {first, first + second + third}
  end)

IO.puts(max)
IO.puts(totalmax)
