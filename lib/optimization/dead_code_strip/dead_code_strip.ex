defmodule MacroCompiler.Optimization.DeadCodeStrip do
  alias MacroCompiler.Parser.Macro
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.HashVariable

  alias MacroCompiler.Optimization.DeadCodeStrip.Variables, as: DeadCodeStripVariables

  def optimize(ast, symbols_table) do
    tips = %{
      variables_never_read: DeadCodeStripVariables.validate_variables(symbols_table)
    }

    run(ast, tips)
  end


  defp run({_node, %{ignore: true}} = node, _tips) do
    node
  end

  defp run({node, metadata}, tips) do
    run_result = run(node, tips)

    case run_result do
      {node, true} ->
        {node, %{metadata | ignore: true}}

      {node, false} ->
        {node, metadata}
    end
  end

  defp run(block, tips) when is_list(block) do
    Enum.map(block, fn block -> run(block, tips) end)
  end

  defp run(%Macro{name: name, block: block}, tips) do
    {%Macro{name: name, block: run(block, tips)}, false}
  end

  defp run(
    %{scalar_variable: {%ScalarVariable{name: scalar_name}, _metadata}} = node,
    %{variables_never_read: variables_never_read})
  do
    case Enum.member?(variables_never_read, "$#{scalar_name}") do
      true ->
        {node, true}

      false ->
        {node, false}
    end
  end

  defp run(
    %{array_variable: {%ArrayVariable{name: array_name}, _metadata}} = node,
    %{variables_never_read: variables_never_read})
  do
    case Enum.member?(variables_never_read, "@#{array_name}") do
      true ->
        {node, true}

      false ->
        {node, false}
    end
  end

  defp run(
    %{hash_variable: {%HashVariable{name: hash_name}, _metadata}} = node,
    %{variables_never_read: variables_never_read})
  do
    case Enum.member?(variables_never_read, "%#{hash_name}") do
      true ->
        {node, true}

      false ->
        {node, false}
    end
  end

  defp run(undefinedNode, _tips) do
    {undefinedNode, false}
  end
end
