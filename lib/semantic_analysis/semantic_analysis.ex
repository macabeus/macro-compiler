defmodule MacroCompiler.SemanticAnalysis do
  alias MacroCompiler.MacroSymbolsTable

  alias MacroCompiler.Macro
  alias MacroCompiler.CallExpression
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression
  alias MacroCompiler.UndefScalarVariable
  alias MacroCompiler.ScalarVariableAssignment
  alias MacroCompiler.ArrayVariableAssignment
  alias MacroCompiler.HashVariableAssignment
  alias MacroCompiler.ScalarVariable
  alias MacroCompiler.ArrayVariable
  alias MacroCompiler.HashVariable
  alias MacroCompiler.IncrementExpression
  alias MacroCompiler.DecrementExpression
  alias MacroCompiler.PushExpression
  alias MacroCompiler.PopExpression
  alias MacroCompiler.TextValue
  alias MacroCompiler.ShiftExpression
  alias MacroCompiler.UnshiftExpression

  alias MacroCompiler.SemanticAnalysisError
  import MacroCompiler.CheckVariablesUse

  def start_validate(ast, table) do
    validate_tree =
      validate(ast, ast, table)
      |> List.flatten

    validate_check_variables_use(validate_tree)
  end

  defp validate(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(validate(&1, ast, symbolsTable)))
  end


  defp validate(%Macro{name: _name, block: block}, ast, symbolsTable) do
    validate(block, ast, symbolsTable)
  end

  defp validate(%CallExpression{macro: macro, params: _params}, _ast, symbolsTable) do
    macroNameExists = Enum.find(
      symbolsTable,
      fn %MacroSymbolsTable{name: ^macro} -> true; _ -> false end
    )

    if macroNameExists == nil do
      raise SemanticAnalysisError,
        message: "'call' expression invalid: macro '#{macro}' doesn't exits!"
    end
  end

  defp validate(%DoExpression{text: text}, ast, symbolsTable) do
    %{
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%LogExpression{text: text}, ast, symbolsTable) do
    %{
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%ScalarVariableAssignment{scalar_variable: scalar_variable, text: text}, ast, symbolsTable) do
    %{
      variable_write: validate(scalar_variable, ast, symbolsTable),
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%ArrayVariableAssignment{array_variable: array_variable, texts: texts}, ast, symbolsTable) do
    %{
      variable_write: validate(array_variable, ast, symbolsTable),
      variable_read: validate(texts, ast, symbolsTable)
    }
  end

  defp validate(%HashVariableAssignment{hash_variable: hash_variable, keystexts: keystexts}, ast, symbolsTable) do
    %{
      variable_write: validate(hash_variable, ast, symbolsTable),
      variable_read: validate(keystexts, ast, symbolsTable)
    }
  end

  defp validate(%UndefScalarVariable{scalar_variable: scalar_variable}, ast, symbolsTable) do
    %{
      variable_write: validate(scalar_variable, ast, symbolsTable)
    }
  end

  defp validate(%IncrementExpression{scalar_variable: scalar_variable}, ast, symbolsTable) do
    %{
      variable_write: validate(scalar_variable, ast, symbolsTable)
    }
  end

  defp validate(%DecrementExpression{scalar_variable: scalar_variable}, ast, symbolsTable) do
    %{
      variable_write: validate(scalar_variable, ast, symbolsTable)
    }
  end

  defp validate(%PushExpression{array_variable: array_variable, text: text}, ast, symbolsTable) do
    %{
      variable_write: validate(array_variable, ast, symbolsTable),
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%PopExpression{array_variable: array_variable}, ast, symbolsTable) do
    %{
      variable_read: validate(array_variable, ast, symbolsTable)
    }
  end

  defp validate(%ShiftExpression{array_variable: array_variable}, ast, symbolsTable) do
    %{
      variable_read: validate(array_variable, ast, symbolsTable)
    }
  end

  defp validate(%UnshiftExpression{array_variable: array_variable, text: text}, ast, symbolsTable) do
    %{
      variable_write: validate(array_variable, ast, symbolsTable),
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%ScalarVariable{name: name, array_position: _array_position, hash_position: _hash_position}, _ast, _symbolsTable) do
    %{
      variable_name: "$#{name}"
    }
  end

  defp validate(%ArrayVariable{name: name}, _ast, _symbolsTable) do
    %{
      variable_name: "@#{name}"
    }
  end

  defp validate(%HashVariable{name: name}, _ast, _symbolsTable) do
    %{
      variable_name: "%#{name}"
    }
  end

  defp validate(%TextValue{values: values}, ast, symbolsTable) do
    values
    |> Enum.map(&(
      case &1 do
        %ScalarVariable{name: _name, array_position: _array_position, hash_position: _hash_position} ->
          validate(&1, ast, symbolsTable)

        %ArrayVariable{name: _name} ->
          validate(&1, ast, symbolsTable)

        %HashVariable{name: _name} ->
          validate(&1, ast, symbolsTable)

        _ ->
          nil
      end)
    )
  end

  defp validate(_undefinedNode, _ast, _symbolsTable) do

  end
end
