defmodule Crane do
  @moduledoc """
  The ElfCrane9000 genserver
  """

  use GenServer

  @impl GenServer
  def init(stacks) do
    {:ok, stacks}
  end

  @impl GenServer
  def handle_call({:move, origin, dest}, _, stacks) do
    # 0-indexed offset
    origin = origin - 1
    dest = dest - 1

    {crate, origin_mod} = elem(stacks, origin) |> List.pop_at(0)
    dest_mod = elem(stacks, dest) |> List.insert_at(0, crate)

    new_stacks =
      stacks
      |> put_elem(origin, origin_mod)
      |> put_elem(dest, dest_mod)

    {:reply, :ok, new_stacks}
  end

  @impl GenServer
  def handle_call(:top, _, stacks) do
    top =
      stacks
      |> Tuple.to_list()
      |> Enum.map(&hd/1)
      |> List.to_string()

    {:reply, top, stacks}
  end
end

# Can't be arsed to parse this
stacks = {
  ["T", "R", "D", "H", "Q", "N", "P", "B"],
  ["V", "T", "J", "B", "G", "W"],
  ["Q", "M", "V", "S", "D", "H", "R", "N"],
  ["C", "M", "N", "Z", "P"],
  ["B", "Z", "D"],
  ["Z", "W", "C", "V"],
  ["S", "L", "Q", "V", "C", "N", "Z", "G"],
  ["V", "N", "D", "M", "J", "G", "L"],
  ["G", "C", "Z", "F", "M", "P", "T"]
}

GenServer.start_link(Crane, stacks, name: ElfCrane9000)

File.read!("./input")
|> String.split("\n", trim: true)
|> Enum.map(fn command ->
  [times, origin, dest] =
    Regex.run(~r/move (\d+) from (\d+) to (\d+)/, command, capture: :all_but_first)

  [String.to_integer(times), String.to_integer(origin), String.to_integer(dest)]
end)
|> Enum.each(fn [times, origin, dest] ->
  Enum.each(1..times, fn _ ->
    GenServer.call(ElfCrane9000, {:move, origin, dest})
  end)
end)

ElfCrane9000
|> GenServer.call(:top)
|> dbg()
