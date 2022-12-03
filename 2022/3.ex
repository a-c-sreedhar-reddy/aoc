<<aasci::utf8>> = "a"
<<zasci::utf8>> = "z"
<<capAasci::utf8>> = "A"

sol =
  File.read!("./data/3.txt")
  |> String.split("\n")
  |> Enum.map(fn input -> String.split_at(input, round(String.length(input) / 2)) end)
  |> Enum.map(fn {first, second} ->
    String.graphemes(first)
    |> Enum.find(fn char ->
      second |> String.contains?(char)
    end)
  end)
  |> Enum.map(fn char ->
    <<asci::utf8>> = char
    if aasci <= asci && asci <= zasci, do: asci - aasci + 1, else: asci - capAasci + 27
  end)
  |> Enum.sum()

IO.puts(sol)

sol2 =
  File.read!("./data/3.txt")
  |> String.split("\n")
  |> List.foldl({[], []}, fn line, {sacks, current_sack} ->
    new_sack = [line | current_sack]
    new_sack_length = length(new_sack)

    if new_sack_length == 3,
      do: {[new_sack | sacks], []},
      else: {sacks, new_sack}
  end)
  |> then(fn {sacks, _} -> sacks end)
  |> Enum.map(fn [first, second, third] ->
    String.graphemes(first)
    |> Enum.find(fn char ->
      second |> String.contains?(char) && third |> String.contains?(char)
    end)
  end)
  |> Enum.map(fn char ->
    <<asci::utf8>> = char
    if aasci <= asci && asci <= zasci, do: asci - aasci + 1, else: asci - capAasci + 27
  end)
  |> Enum.sum()

IO.puts(sol2)
