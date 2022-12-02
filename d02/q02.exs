move_fn = fn
  "A" -> "rock"
  "B" -> "paper"
  "C" -> "scissors"
  "X" -> "lose"
  "Y" -> "draw"
  "Z" -> "win"
end

predictor_fn = fn
  {"win", "rock"} ->
    {"paper", "rock"}

  {"win", "paper"} ->
    {"scissors", "paper"}

  {"win", "scissors"} ->
    {"rock", "scissors"}

  {"lose", "rock"} ->
    {"scissors", "rock"}

  {"lose", "paper"} ->
    {"rock", "paper"}

  {"lose", "scissors"} ->
    {"paper", "scissors"}

  {"draw", cpu_move} ->
    {cpu_move, cpu_move}
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
  |> predictor_fn.()
  |> result_fn.()
end)
|> Enum.sum()
|> dbg()
