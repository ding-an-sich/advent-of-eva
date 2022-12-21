defmodule TreeSpotter do
  def look(row) do
    {_, seen} =
      Enum.reduce(row, {-1, []}, fn tree, {highest_tree, seen} = acc ->
        if tree.height > highest_tree,
          do: {tree.height, seen ++ [tree]},
          else: acc
      end)

    reversed_row = Enum.reverse(row)

    {_, seen_reversed} =
      Enum.reduce(reversed_row, {-1, []}, fn tree, {highest_tree, seen} = acc ->
        if tree.height > highest_tree,
          do: {tree.height, seen ++ [tree]},
          else: acc
      end)

    seen ++ seen_reversed
  end
end

defmodule Tree do
  defstruct [:x, :y, :height]
end

defmodule Grid do
  def make_grid do
    File.read!("./input")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(&Enum.with_index/1)
    |> Enum.with_index(fn row, i ->
      Enum.map(row, fn {z, x} ->
        {x, i, String.to_integer(z)}
      end)
    end)
    |> Enum.map(fn row ->
      Enum.map(row, fn {x, y, z} ->
        %Tree{
          x: x,
          y: y,
          height: z
        }
      end)
    end)
  end

  @doc """
  Switches the x and y positions
  of a two-dimensional grid of trees.

  Not sure if this operation is called
  transpose, I'm just trying to be clever here.
  """
  def transpose(grid) do
    grid
    |> Enum.flat_map(& &1)
    |> Enum.reduce(%{}, fn tree, map ->
      {_, map} =
        Map.get_and_update(map, tree.x, fn
          nil -> {nil, [tree]}
          trees -> {trees, trees ++ [tree]}
        end)

      map
    end)
    |> Enum.map(fn {_y, row} -> row end)
  end
end

grid = Grid.make_grid()
transposed = Grid.transpose(grid)
left_right_look = Enum.flat_map(grid, &TreeSpotter.look/1)
up_down_look = Enum.flat_map(transposed, &TreeSpotter.look/1)

(left_right_look ++ up_down_look) |> Enum.uniq() |> Enum.count() |> dbg()
