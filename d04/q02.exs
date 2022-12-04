File.read!("./input")
|> String.split("\n", trim: true)
|> Enum.map(fn ranges ->
  [r1s, r1e, r2s, r2e] =
    ~r/^(\d+)-(\d+),(\d+)-(\d+)/
    |> Regex.run(ranges, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)

  {
    MapSet.new(r1s..r1e),
    MapSet.new(r2s..r2e)
  }
end)
|> Enum.reject(fn {range1, range2} ->
  MapSet.disjoint?(range1, range2)
end)
|> Enum.count()
|> dbg()
