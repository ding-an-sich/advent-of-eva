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
|> Enum.chunk_every(3)
|> Enum.map(fn [sack1, sack2, sack3] ->
  sack1_set = sack1 |> String.graphemes() |> MapSet.new()
  sack2_set = sack2 |> String.graphemes() |> MapSet.new()
  sack3_set = sack3 |> String.graphemes() |> MapSet.new()

  badge =
    sack1_set
    |> MapSet.intersection(sack2_set)
    |> MapSet.intersection(sack3_set)
    |> MapSet.to_list()
    |> hd()

  priorities[badge]
end)
|> Enum.sum()
|> dbg()
