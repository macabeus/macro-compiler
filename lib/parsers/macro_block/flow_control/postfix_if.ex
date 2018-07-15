defmodule MacroCompiler.Parser.PostfixIf do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.PostfixIf

  @enforce_keys [:condition]
  defstruct [:condition, :body]

  parser_command do
    sequence([
      skip(spaces()),

      ignore(string("if (")),

      either(
        char("0"),
        char("1")
      ),

      ignore(string(")"))
    ])
  end

  def map_command([condition]) do
    %PostfixIf{condition: condition}
  end
end

