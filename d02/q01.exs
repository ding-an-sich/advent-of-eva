move_fn = fn
  "A" -> "rock"
  "B" -> "paper"
  "C" -> "scissors"
  "X" -> "rock"
  "Y" -> "paper"
  "Z" -> "scissors"
end

result_fn = fn
  {"rock", "scissors"} -> 6 + 1
  {"rock", "rock"} -> 3 + 1
  {"rock", "paper"} -> 0 + 1
  {"paper", "rock"} -> 6 + 2
  {"paper", "paper"} -> 3 + 2
  {"paper", "scissors"} -> 0 + 2
  {"scissors", "paper"} -> 6 + 3
  {"scissors", "scissors"} -> 3 + 3
  {"scissors", "rock"} -> 0 + 3
end

File.read!("./input")
|> String.split("\n", trim: true)
|> Enum.map(fn game ->
  [cpu, p1] = String.split(game)

  {
    move_fn.(p1),
    move_fn.(cpu)
  }
  |> result_fn.()
end)
|> Enum.sum()
|> dbg()
