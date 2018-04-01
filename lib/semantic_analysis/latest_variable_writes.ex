defmodule MacroCompiler.SemanticAnalysis.LatestVariableWrites do
  alias MacroCompiler.Parser.ScalarAssignmentCommand
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.TextValue


  def build(block) do
    Enum.map(block, &list_variables_assignments/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(%{}, fn (variavel, acc) ->
      Map.put(acc, variavel.name, variavel.determinist)
    end)
  end

  defp list_variables_assignments({
    %ScalarAssignmentCommand{
      scalar_variable: {%ScalarVariable{name: name, array_position: nil, hash_position: nil}, _},
      scalar_value: scalar_value
    },
    _metadata
  }) do
    %{
      name: name,
      determinist: determinist_value(scalar_value)
    }
  end

  defp list_variables_assignments(_node) do

  end

  defp determinist_value(%TextValue{} = node) do
    node
  end

  defp determinist_value(_node) do
    :is_not_determinist
  end
end
