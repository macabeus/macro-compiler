defmodule MacroCompiler.Parser.UndefCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.UndefCommand
  alias MacroCompiler.Parser.ScalarVariable

  @enforce_keys [:scalar_variable]
  defstruct [:scalar_variable]

  parser_command do
    sequence([
      ScalarVariable.parser(),

      skip(spaces()),
      ignore(string("=")),
      skip(spaces()),

      ignore(choice([
        string("undef"),
        string("unset")
      ])),

      ignore(char(?\n))
    ])
  end

  def map_command([scalar_variable]) do
    %UndefCommand{scalar_variable: scalar_variable}
  end
end
