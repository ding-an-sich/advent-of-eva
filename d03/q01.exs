lowercase =
  ?a..?z
  |> Enum.to_list()
  |> List.to_string()
  |> String.graphemes()

uppercase =
  ?A..?Z
  |> Enum.to_list()
  |> List.to_string()
  |> String.graphemes()

priorities =
  lowercase
  |> Kernel.++(uppercase)
  |> then(fn abc -> Enum.zip([abc, 1..52]) end)
  |> Map.new()

File.read!("./input")
|> String.split("\n", trim: true)
|> Enum.map(fn rucksack ->
  half = rucksack |> String.length() |> div(2)
  {cpt1, cpt2} = String.split_at(rucksack, half)

  {
    cpt1 |> String.graphemes() |> MapSet.new(),
    cpt2 |> String.graphemes() |> MapSet.new()
  }
end)
|> Enum.map(fn {cpt1, cpt2} ->
  dupe = cpt1 |> MapSet.intersection(cpt2) |> MapSet.to_list() |> hd()
  priorities[dupe]
end)
|> Enum.sum()
|> dbg()
