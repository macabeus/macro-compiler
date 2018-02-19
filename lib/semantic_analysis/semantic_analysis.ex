defmodule MacroCompiler.SemanticAnalysis do
  alias MacroCompiler.Parser.Macro
  alias MacroCompiler.Parser.CallCommand
  alias MacroCompiler.Parser.DoCommand
  alias MacroCompiler.Parser.LogCommand
  alias MacroCompiler.Parser.UndefCommand
  alias MacroCompiler.Parser.ScalarAssignmentCommand
  alias MacroCompiler.Parser.ArrayAssignmentCommand
  alias MacroCompiler.Parser.HashAssignmentCommand
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.HashVariable
  alias MacroCompiler.Parser.IncrementCommand
  alias MacroCompiler.Parser.DecrementCommand
  alias MacroCompiler.Parser.PushCommand
  alias MacroCompiler.Parser.PopCommand
  alias MacroCompiler.Parser.TextValue
  alias MacroCompiler.Parser.ShiftCommand
  alias MacroCompiler.Parser.UnshiftCommand

  alias MacroCompiler.SemanticAnalysisError
  import MacroCompiler.CheckVariablesUse
  import MacroCompiler.CheckMacros

  def start_validate(ast, table) do
    validate_tree =
      validate(ast, ast, table)
      |> List.flatten

    validate_check_variables_use(validate_tree)
    validate_check_macros(validate_tree)
  end

  defp validate(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(validate(&1, ast, symbolsTable)))
  end


  defp validate(%Macro{name: name, block: block}, ast, symbolsTable) do
    %{
      macro_write: %{name: name, block: validate(block, ast, symbolsTable)}
    }
  end

  defp validate(%CallCommand{macro: macro, params: params}, _ast, symbolsTable) do
    %{
      macro_read: %{name: macro, params: params}
    }
  end

  defp validate(%DoCommand{text: text}, ast, symbolsTable) do
    %{
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%LogCommand{text: text}, ast, symbolsTable) do
    %{
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%ScalarAssignmentCommand{scalar_variable: scalar_variable, text: text}, ast, symbolsTable) do
    %{
      variable_write: validate(scalar_variable, ast, symbolsTable),
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%ArrayAssignmentCommand{array_variable: array_variable, texts: texts}, ast, symbolsTable) do
    %{
      variable_write: validate(array_variable, ast, symbolsTable),
      variable_read: validate(texts, ast, symbolsTable)
    }
  end

  defp validate(%HashAssignmentCommand{hash_variable: hash_variable, keystexts: keystexts}, ast, symbolsTable) do
    %{
      variable_write: validate(hash_variable, ast, symbolsTable),
      variable_read: validate(keystexts, ast, symbolsTable)
    }
  end

  defp validate(%UndefCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    %{
      variable_write: validate(scalar_variable, ast, symbolsTable)
    }
  end

  defp validate(%IncrementCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    %{
      variable_write: validate(scalar_variable, ast, symbolsTable)
    }
  end

  defp validate(%DecrementCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    %{
      variable_write: validate(scalar_variable, ast, symbolsTable)
    }
  end

  defp validate(%PushCommand{array_variable: array_variable, text: text}, ast, symbolsTable) do
    %{
      variable_write: validate(array_variable, ast, symbolsTable),
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%PopCommand{array_variable: array_variable}, ast, symbolsTable) do
    %{
      variable_read: validate(array_variable, ast, symbolsTable)
    }
  end

  defp validate(%ShiftCommand{array_variable: array_variable}, ast, symbolsTable) do
    %{
      variable_read: validate(array_variable, ast, symbolsTable)
    }
  end

  defp validate(%UnshiftCommand{array_variable: array_variable, text: text}, ast, symbolsTable) do
    %{
      variable_write: validate(array_variable, ast, symbolsTable),
      variable_read: validate(text, ast, symbolsTable)
    }
  end

  defp validate(%ScalarVariable{name: name, array_position: array_position, hash_position: hash_position} = x, ast, symbolsTable) do
    case {array_position, hash_position} do
      {nil, nil} ->
        %{
          variable_name: "$#{name}"
        }

      {array_position, nil} ->
        %{
          variable_name: "@#{name}",
          variable_read: validate(array_position, ast, symbolsTable)
        }

      {nil, hash_position} ->
        %{
          variable_name: "%#{name}",
          variable_read: validate(hash_position, ast, symbolsTable)
        }
    end
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
