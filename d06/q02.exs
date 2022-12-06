File.read!("./input")
|> String.trim()
|> String.graphemes()
|> Enum.with_index()
|> Enum.chunk_every(14, 1)
|> Enum.reduce_while([], fn chunk, acc ->
  if chunk
     |> Enum.uniq_by(fn {a, _} -> a end)
     |> length() ==
       length(chunk) do
    {_, i} = chunk |> List.last()
    {:halt, i + 1}
  else
    {:cont, []}
  end
end)
|> dbg()
