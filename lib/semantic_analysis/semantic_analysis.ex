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
  alias MacroCompiler.Parser.DeleteCommand
  alias MacroCompiler.Parser.KeysCommand
  alias MacroCompiler.Parser.ValuesCommand
  alias MacroCompiler.Parser.RandCommand
  alias MacroCompiler.Parser.RandomCommand
  alias MacroCompiler.Parser.PostfixIf
  alias MacroCompiler.Parser.Condition
  alias MacroCompiler.Parser.IfBlock
  alias MacroCompiler.Parser.SingleCheck

  alias MacroCompiler.SemanticAnalysis.LatestVariableWrites
  alias MacroCompiler.SemanticAnalysis.SymbolsTable

  import MacroCompiler.SemanticAnalysis.Validates.Variables
  import MacroCompiler.SemanticAnalysis.Validates.Macros
  import MacroCompiler.SemanticAnalysis.Validates.SpecialVariables

  def build_symbols_table(ast) do
    symbols_table =
      symbols_table(ast)
      |> List.flatten

    %{macros: symbols_table, special_variables: SymbolsTable.list_special_variables(symbols_table)}
  end

  def run_validates(symbols_table) do
    List.flatten([
      validate_variables(symbols_table),
      validate_macros(symbols_table),
      validate_special_variables(symbols_table)
    ])
  end


  defp symbols_table(block) when is_list(block) do
    Enum.map(block, &symbols_table/1)
  end

  defp symbols_table({_node, %{ignore: true}}) do

  end


  defp symbols_table({%Macro{name: name, block: block}, _metadata}) do
    %{
      macro_write: %{
        name: name,
        block: symbols_table(block),
        last_write_variables: LatestVariableWrites.build(block)
      }
    }
  end

  defp symbols_table({%CallCommand{macro: macro, params: params}, metadata}) do
    %{
      macro_read: {%{name: macro, params: params}, metadata}
    }
  end

  defp symbols_table({%DoCommand{text: text}, _metadata}) do
    %{
      variable_read: symbols_table(text)
    }
  end

  defp symbols_table({%LogCommand{text: text}, _metadata}) do
    %{
      variable_read: symbols_table(text)
    }
  end

  defp symbols_table({%ScalarAssignmentCommand{scalar_variable: scalar_variable, scalar_value: scalar_value}, _metadata}) do
    %{
      variable_write: symbols_table(scalar_variable),
      variable_read: symbols_table(scalar_value)
    }
  end

  defp symbols_table({%ArrayAssignmentCommand{array_variable: array_variable, texts: texts}, _metadata}) do
    %{
      variable_write: symbols_table(array_variable),
      variable_read: symbols_table(texts)
    }
  end

  defp symbols_table({%HashAssignmentCommand{hash_variable: hash_variable, keystexts: keystexts}, _metadata}) do
    %{
      variable_write: symbols_table(hash_variable),
      variable_read: symbols_table(keystexts)
    }
  end

  defp symbols_table({%UndefCommand{scalar_variable: scalar_variable}, _metadata}) do
    %{
      variable_write: symbols_table(scalar_variable)
    }
  end

  defp symbols_table({%IncrementCommand{scalar_variable: scalar_variable}, _metadata}) do
    %{
      variable_write: symbols_table(scalar_variable)
    }
  end

  defp symbols_table({%DecrementCommand{scalar_variable: scalar_variable}, _metadata}) do
    %{
      variable_write: symbols_table(scalar_variable)
    }
  end

  defp symbols_table({%PushCommand{array_variable: array_variable, text: text}, _metadata}) do
    %{
      variable_write: symbols_table(array_variable),
      variable_read: symbols_table(text)
    }
  end

  defp symbols_table({%PopCommand{array_variable: array_variable}, _metadata}) do
    %{
      variable_read: symbols_table(array_variable)
    }
  end

  defp symbols_table({%ShiftCommand{array_variable: array_variable}, _metadata}) do
    %{
      variable_read: symbols_table(array_variable)
    }
  end

  defp symbols_table({%UnshiftCommand{array_variable: array_variable, text: text}, _metadata}) do
    %{
      variable_write: symbols_table(array_variable),
      variable_read: symbols_table(text)
    }
  end

  defp symbols_table({%ScalarVariable{name: name, array_position: array_position, hash_position: hash_position}, metadata}) do
    case {array_position, hash_position} do
      {nil, nil} ->
        %{
          variable_name: {"$#{name}", metadata}
        }

      {array_position, nil} ->
        %{
          variable_name: {"@#{name}", metadata},
          variable_read: symbols_table(array_position)
        }

      {nil, hash_position} ->
        %{
          variable_name: {"%#{name}", metadata},
          variable_read: symbols_table(hash_position)
        }
    end
  end

  defp symbols_table({%ArrayVariable{name: name}, metadata}) do
    %{
      variable_name: {"@#{name}", metadata}
    }
  end

  defp symbols_table({%HashVariable{name: name}, metadata}) do
    %{
      variable_name: {"%#{name}", metadata}
    }
  end

  defp symbols_table({%DeleteCommand{scalar_variable: scalar_variable}, _metadata}) do
    %{
      variable_write: symbols_table(scalar_variable)
    }
  end

  defp symbols_table({%KeysCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}, _metadata}) do
    %{
      variable_write: symbols_table(array_variable),
      variable_read: symbols_table(param_hash_variable)
    }
  end

  defp symbols_table({%ValuesCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}, _metadata}) do
    %{
      variable_write: symbols_table(array_variable),
      variable_read: symbols_table(param_hash_variable)
    }
  end

  defp symbols_table(%TextValue{values: values}) do
    values
    |> Enum.map(&(
      case &1 do
        {%ScalarVariable{name: _name, array_position: _array_position, hash_position: _hash_position}, _metadata} ->
          symbols_table(&1)

        {%ArrayVariable{name: _name}, _metadata} ->
          symbols_table(&1)

        {%HashVariable{name: _name}, _metadata} ->
          symbols_table(&1)

        _ ->
          nil
      end)
    )
  end

  defp symbols_table({%RandCommand{min: min, max: max}, _metadata}) do
    [min, max]
    |> Enum.map(&(
      %{
        variable_read: symbols_table(&1)
      }
    ))
  end

  defp symbols_table({%RandomCommand{values: values}, _metadata}) do
    values
    |> Enum.map(&(
      %{
        variable_read: symbols_table(&1)
      }
    ))
  end

  defp symbols_table({%PostfixIf{condition: condition, block: block}, _metadata}) do
    [
      %{variable_read: symbols_table(condition)},
      %{variable_read: symbols_table(block)},
      %{variable_write: symbols_table(block)}
    ]
  end

  defp symbols_table({%IfBlock{condition: condition, block: block}, _metadata}) do
    [
      %{variable_read: symbols_table(condition)},
      %{variable_read: symbols_table(block)},
      %{variable_write: symbols_table(block)}
    ]
  end

  defp symbols_table({%Condition{scalar_variable: scalar_variable, value: value}, _metadata}) do
    [scalar_variable, value]
    |> Enum.map(&(
      %{
        variable_read: symbols_table(&1)
      }
    ))
  end

  defp symbols_table({%SingleCheck{scalar_variable: scalar_variable}, _metadata}) do
    [
      %{variable_read: symbols_table(scalar_variable)}
    ]
  end

  defp symbols_table(_undefinedNode) do

  end
end
