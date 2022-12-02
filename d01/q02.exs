File.read!("./input")
|> String.split("\n")
|> Enum.map(fn
  "" -> ""
  cal -> cal |> Integer.parse() |> elem(0)
end)
|> Enum.chunk_by(&(&1 == ""))
|> Enum.reject(&(&1 == [""]))
|> Enum.map(&Enum.sum/1)
|> Enum.sort(:desc)
|> Enum.take(3)
|> Enum.sum()
|> dbg()
