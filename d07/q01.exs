Mix.install([
  :nimble_parsec
])

defmodule DirParser do
  import NimbleParsec

  command =
    ignore(string("$ "))
    |> ascii_string([?a..?z, ?A..?Z], min: 1)
    |> ignore(optional(string(" ")))
    |> optional(ascii_string([?!..?~], min: 1))
    |> tag(:command)
    |> post_traverse(:traverse)

  directory =
    ignore(string("dir "))
    |> ascii_string([?a..?z, ?A..?Z], min: 1)
    |> unwrap_and_tag(:directory)
    |> post_traverse(:traverse)

  file =
    integer(min: 1)
    |> ignore(string(" "))
    |> ascii_string([?!..?~], min: 1)
    |> tag(:file)
    |> post_traverse(:traverse)

  newline = ignore(string("\n"))

  parser =
    choice([command, directory, file, newline])
    |> repeat()

  defparsec(:commands, parser)

  # Go up
  def traverse(_rest, [command: ["cd", ".."]], %{current_dir: dir, tree: tree} = ctx, _, _) do
    up = tree[dir].parent
    ctx = %{ctx | current_dir: up}
    {[], ctx}
  end

  def traverse(_rest, [command: ["cd", "/"]], %{tree: tree, current_dir: nil}, _, _) do
    node = %{contents: [], children: [], parent: nil}
    ctx = %{tree: Map.put(tree, "/", node), current_dir: "/"}
    {[], ctx}
  end

  # Produce a new node when entering a directory
  def traverse(_rest, [command: ["cd", dir]], %{tree: tree, current_dir: parent}, _, _) do
    node = %{contents: [], children: [], parent: parent}
    ctx = %{tree: Map.put(tree, "#{parent}/#{dir}", node), current_dir: "#{parent}/#{dir}"}
    {[], ctx}
  end

  # Put file contents into current node
  def traverse(_rest, [file: [size, filename]], %{current_dir: dir, tree: tree} = ctx, _, _) do
    node = Map.fetch!(tree, dir)

    updated_node =
      Map.update!(node, :contents, fn contents ->
        contents ++ [{filename, size}]
      end)

    ctx = %{
      ctx
      | tree: Map.put(tree, dir, updated_node)
    }

    {[], ctx}
  end

  # Assign a new child to the current node
  def traverse(_rest, [directory: dir_name], %{current_dir: dir, tree: tree} = ctx, _, _) do
    node = Map.fetch!(tree, dir)

    updated_node =
      Map.update!(node, :children, fn children ->
        children ++ ["#{dir}/#{dir_name}"]
      end)

    ctx = %{
      ctx
      | tree: Map.put(tree, dir, updated_node)
    }

    {[], ctx}
  end

  def traverse(rest, _hello, ctx, _, _) do
    {rest, [], ctx}
  end
end

defmodule ContentSize do
  def total(%{children: [], contents: contents}, _tree, acc) do
    content_size = Enum.reduce(contents, 0, fn {_, size}, acc -> size + acc end)
    acc + content_size
  end

  def total(%{children: children, contents: contents}, tree, acc) do
    content_size = Enum.reduce(contents, 0, fn {_, size}, acc -> size + acc end)

    children_size =
      Enum.map(children, fn child ->
        child_node = tree[child]
        ContentSize.total(child_node, tree, acc)
      end)
      |> Enum.sum()

    content_size + children_size + acc
  end
end

# Set initial ctx
ctx = %{tree: %{}, current_dir: nil}

# Parse directory tree
{:ok, [], "", %{tree: directory_tree}, _, _} =
  File.read!("./input")
  |> DirParser.commands(context: ctx)

# Traverse the tree fetching directory size
# and filter for sizes <= 100_000
directory_tree
|> Enum.map(fn {dirname, node} ->
  size = ContentSize.total(node, directory_tree, 0)
  {dirname, size}
end)
|> Enum.map(fn {_, size} -> if size <= 100_000, do: size, else: 0 end)
|> Enum.sum()
|> dbg()
