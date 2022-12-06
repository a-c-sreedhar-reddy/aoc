defmodule Device do
  defp are_unique(l) do
    Enum.uniq(l) == l
  end

  defp get_marker_n(stream, n, marker_length) do
    stream_length = length(stream)

    if stream_length < marker_length - 1,
      do: -1,
      else:
        if(Enum.take(stream, marker_length) |> are_unique(),
          do: marker_length + n,
          else: get_marker_n(tl(stream), n + 1, marker_length)
        )
  end

  def get_marker_four(stream) do
    get_marker_n(stream, 0, 4)
  end

  def get_marker_fourteen(stream) do
    get_marker_n(stream, 0, 14)
  end
end

stream = File.read!("./data/6.txt") |> String.graphemes()

stream |> Device.get_marker_four() |> IO.puts()

stream |> Device.get_marker_fourteen() |> IO.puts()
