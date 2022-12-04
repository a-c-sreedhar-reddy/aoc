parsed_data =
  File.read!("./data/4.txt")
  |> String.split("\n")
  |> Enum.map(fn line ->
    String.split(line, ",")
    |> Enum.map(fn range ->
      String.split(range, "-") |> Enum.map(fn value -> String.to_integer(value) end)
    end)
  end)

parsed_data
|> Enum.filter(fn [[start1, end1], [start2, end2]] ->
  (start1 <= start2 && start2 <= end1 && start1 <= end2 && end2 <= end1) ||
    (start2 <= start1 && start1 <= end2 && start2 <= end1 && end1 <= end2)
end)
|> length()
|> IO.puts()

parsed_data
|> Enum.filter(fn [[start1, end1], [start2, end2]] ->
  (start1 <= start2 && start2 <= end1) || (start1 <= end2 && end2 <= end1) ||
    ((start2 <= start1 && start1 <= end2) || (start2 <= end1 && end1 <= end2))
end)
|> length()
|> IO.puts()
