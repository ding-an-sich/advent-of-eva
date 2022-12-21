defmodule TreeSpotter do
  def scenic_value(target_tree, grid) do
    target_tree_x = target_tree.x
    target_tree_y = target_tree.y

    scenic_right =
      grid
      |> Enum.filter(fn tree ->
        tree.y == target_tree_y and tree.x > target_tree_x
      end)
      |> Enum.sort_by(& &1.x)
      |> count_visible_trees(target_tree)

    scenic_left =
      grid
      |> Enum.filter(fn tree ->
        tree.y == target_tree_y and tree.x < target_tree_x
      end)
      |> Enum.sort_by(& &1.x, :desc)
      |> count_visible_trees(target_tree)

    scenic_up =
      grid
      |> Enum.filter(fn tree ->
        tree.x == target_tree_x and tree.y < target_tree_y
      end)
      |> Enum.sort_by(& &1.y, :desc)
      |> count_visible_trees(target_tree)

    scenic_down =
      grid
      |> Enum.filter(fn tree ->
        tree.x == target_tree_x and tree.y > target_tree_y
      end)
      |> Enum.sort_by(& &1.y)
      |> count_visible_trees(target_tree)

    scenic_right * scenic_left * scenic_down * scenic_up
  end

  def count_visible_trees(slice, target_tree) do
    {visible_trees, _} =
      Enum.reduce_while(slice, {0, 0}, fn tree, {visible_trees, curr} ->
        current_field_height = max(tree.height, curr)

        if target_tree.height > tree.height do
          {:cont, {visible_trees + 1, current_field_height}}
        else
          {:halt, {visible_trees + 1, current_field_height}}
        end
      end)

    visible_trees
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
end

grid = Grid.make_grid()
flattened_grid = Enum.flat_map(grid, & &1)
flattened_grid |> Enum.map(&TreeSpotter.scenic_value(&1, flattened_grid)) |> Enum.max() |> dbg()
