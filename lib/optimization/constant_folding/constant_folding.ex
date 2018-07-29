defmodule MacroCompiler.Optimization.ConstantFolding do
  alias MacroCompiler.Parser.Macro
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.LogCommand
  alias MacroCompiler.Parser.TextValue
  alias MacroCompiler.Parser.CallCommand
  alias MacroCompiler.Parser.RandCommand
  alias MacroCompiler.Parser.ScalarAssignmentCommand
  alias MacroCompiler.Parser.ArrayAssignmentCommand
  alias MacroCompiler.Parser.HashAssignmentCommand
  alias MacroCompiler.Parser.PushCommand


  def optimize(ast, %{macros: symbols_table_macro}) do
    tuple_macro_last_write_variables =
      symbols_table_macro
      |> Enum.map(&{&1.macro_write.name, &1.macro_write.last_write_variables})

    Process.put(:macro_last_write_variables, tuple_macro_last_write_variables)

    optimized_ast =
      ast
      |> Enum.map(
        fn {%Macro{block: block} = node, metadata} ->
          {%{node | block: optimize_block(block).optimized_block}, metadata}
        end
      )

    Process.put(:macro_last_write_variables, nil)

    optimized_ast
  end

  defp optimize_block(block, initial_variables_context\\%{}) do
    {optimized_block, final_variables_context} =
      Enum.reduce(
        block,
        {[], initial_variables_context},
        fn
          ({%{block: block} = block_node, metadata}, {nodes, variables_context}) ->
            %{
              optimized_block: optimized_block,
              variables_writen: variables_writen
            } = optimize_block(block, variables_context)

            {_, variables_context} =
              variables_context
              |> Map.split(variables_writen)

            optimized_block_node = %{block_node | block: optimized_block}

            {[{optimized_block_node, metadata} | nodes], variables_context}

          (current_node, {nodes, variables_context}) ->
            {node, updated_variables_context} =
              run(current_node, variables_context)

            {[node | nodes], updated_variables_context}
        end
      )

    variable_context_differences =
      initial_variables_context
      |> Enum.reject(fn {var_name, var_value} ->
        Map.get(final_variables_context, var_name) == var_value
      end)
      |> Enum.map(fn {var_name, _var_value} ->
        var_name
      end)

    %{
      optimized_block: Enum.reverse(optimized_block),
      variables_writen: variable_context_differences
    }
  end

  defp run({_node, %{ignore: true}} = node, variables_context) do
    {node, variables_context}
  end

  defp run(
    {
      %ScalarAssignmentCommand{
        scalar_variable: {%ScalarVariable{name: scalar_name, array_position: nil, hash_position: nil}, _},
        scalar_value: scalar_value
      } = node,
      metadata
    },
    variables_context
  ) do
    optimized_node =
      {%{node | scalar_value: optimize_scalar_value(scalar_value, variables_context)}, metadata}

    updated_variables_context =
      case scalar_value do
        # determinist value
        %TextValue{} ->
          Map.put(variables_context, scalar_name, scalar_value)

        # non-determinist value
        _ ->
          Map.delete(variables_context, scalar_name)
      end

    {optimized_node, updated_variables_context}
  end

  defp run({%LogCommand{text: text} = node, metadata}, variables_context) do
    {
      {%{node | text: optimize_scalar_value(text, variables_context)}, metadata},
      variables_context
    }
  end

  defp run({%ArrayAssignmentCommand{texts: texts} = node, metadata}, variables_context) do
    optimized_texts =
      texts
      |> Enum.map(&optimize_scalar_value(&1, variables_context))

    {
      {%{node | texts: optimized_texts}, metadata},
      variables_context
    }
  end

  defp run({%HashAssignmentCommand{keystexts: keystexts} = node, metadata}, variables_context) do
    optimized_keystexts =
      keystexts
      |> Enum.map(
        &[
          Enum.at(&1, 0),
          optimize_scalar_value(Enum.at(&1, 1), variables_context)
        ]
      )

    {
      {%{node | keystexts: optimized_keystexts}, metadata},
      variables_context
    }
  end

  defp run({%PushCommand{text: text} = node, metadata}, variables_context) do
    {
      {%{node | text: optimize_scalar_value(text, variables_context)}, metadata},
      variables_context
    }
  end

  defp run({%CallCommand{macro: macro}, _} = node, variables_context) do
    {_macro_name, last_write_variables} =
      List.keyfind(Process.get(:macro_last_write_variables), macro, 0)

    {node, Map.merge(variables_context, last_write_variables)}
  end

  defp run(node, variables_context) do
    {node, variables_context}
  end

  defp optimize_scalar_value({%RandCommand{min: min, max: max}, metadata}, variables_context) do
    {
      {
        %RandCommand{
          min: optimize_scalar_value(min, variables_context),
          max: optimize_scalar_value(max, variables_context)
        },
        metadata
      },

      variables_context
    }
  end

  defp optimize_scalar_value({%ScalarVariable{name: scalar_name, array_position: nil, hash_position: nil}, _metadata} = node, variables_context) do
    case Map.get(variables_context, scalar_name, nil) do
      %TextValue{} = text_value ->
        text_value

      :is_not_determinist ->
        node

      nil ->
        node
    end
  end

  defp optimize_scalar_value(%TextValue{values: values}, variables_context) do
    optimized_values =
      values
      |> Enum.map(&case &1 do
        {%ScalarVariable{name: scalar_name}, _} ->
          case Map.get(variables_context, scalar_name, nil) do
            # determinist value
            %TextValue{values: more_values} ->
              more_values

            # non-determinist value
            _ ->
              &1
          end

        char ->
           char
      end)
      |> List.flatten

    %TextValue{values: optimized_values}
  end

  defp optimize_scalar_value(node, _variables_context) do
    node
  end
end
