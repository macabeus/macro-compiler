defmodule MacroCompiler.Parser.ValuesCommand do
  use Combine

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.HashVariable
  alias MacroCompiler.Parser.ValuesCommand

  @enforce_keys [:array_variable, :param_hash_variable]
  defstruct [:array_variable, :param_hash_variable]

  parser_command do
    sequence([
      ArrayVariable.parser(),

      skip(spaces()),
      ignore(string("=")),
      skip(spaces()),

      ignore(string("&values(")),

      HashVariable.parser(),

      ignore(string(")")),

      skip(newline())
    ])
  end

  def map_command([array_variable, param_hash_variable]) do
    %ValuesCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}
  end
end
