defmodule MacroCompiler.Optimization.DeadCodeStrip do
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.HashVariable

  alias MacroCompiler.SemanticAnalysis.SymbolsTable

  @ignore_node true
  @keep_node false

  def optimize(ast, %{macros: symbols_table_macros}) do
    variables_read =
      symbols_table_macros
      |> SymbolsTable.list_read_variables
      |> Enum.map(fn {name, _} -> name end)
      |> MapSet.new

    variables_written =
      symbols_table_macros
      |> SymbolsTable.list_written_variables
      |> Enum.map(fn {name, _} -> name end)
      |> MapSet.new

   variables_never_read =
      MapSet.difference(variables_written, variables_read)

    tips = %{
      variables_never_read: variables_never_read
    }

    run(ast, tips)
  end


  defp run({_node, %{ignore: true}} = node, _tips) do
    node
  end

  defp run({node, metadata}, tips) do
    run_result = run(node, tips)

    case run_result do
      {node, @ignore_node} ->
        case Process.get(:no_keep_ignored_node) do
          true ->
            nil
          _ ->
            {node, %{metadata | ignore: true}}
        end

      {node, @keep_node} ->
        {node, metadata}
    end
  end

  defp run(block, tips) when is_list(block) do
    Enum.map(block, fn block -> run(block, tips) end)
    |> Enum.reject(&is_nil/1)
  end

  defp run(%{block: block} = node, tips) do
    {
      %{node | block: run(block, tips)},
      @keep_node
    }
  end

  defp run(
    %{scalar_variable: {%ScalarVariable{name: scalar_name}, _metadata}} = node,
    %{variables_never_read: variables_never_read})
  do
    case Enum.member?(variables_never_read, "$#{scalar_name}") do
      true ->
        {node, @ignore_node}

      false ->
        {node, @keep_node}
    end
  end

  defp run(
    %{array_variable: {%ArrayVariable{name: array_name}, _metadata}} = node,
    %{variables_never_read: variables_never_read})
  do
    case Enum.member?(variables_never_read, "@#{array_name}") do
      true ->
        {node, @ignore_node}

      false ->
        {node, @keep_node}
    end
  end

  defp run(
    %{hash_variable: {%HashVariable{name: hash_name}, _metadata}} = node,
    %{variables_never_read: variables_never_read})
  do
    case Enum.member?(variables_never_read, "%#{hash_name}") do
      true ->
        {node, @ignore_node}

      false ->
        {node, @keep_node}
    end
  end

  defp run(undefinedNode, _tips) do
    {undefinedNode, @keep_node}
  end
end
