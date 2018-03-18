defmodule MacroCompiler.Parser.KeysCommand do
  use Combine

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.HashVariable
  alias MacroCompiler.Parser.KeysCommand

  @enforce_keys [:array_variable, :param_hash_variable]
  defstruct [:array_variable, :param_hash_variable]

  parser_command do
    sequence([
      ArrayVariable.parser(),

      skip(spaces()),
      ignore(string("=")),
      skip(spaces()),

      ignore(string("&keys(")),

      HashVariable.parser(),

      ignore(string(")"))
    ])
  end

  def map_command([array_variable, param_hash_variable]) do
    %KeysCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}
  end
end
