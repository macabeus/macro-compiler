defmodule MacroCompiler.Parser.PostfixIf do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.PostfixIf
  alias MacroCompiler.Parser.SingleCheck
  alias MacroCompiler.Parser.Condition

  @enforce_keys [:condition]
  defstruct [:condition, :block]

  parser_command do
    sequence([
      skip(spaces()),

      ignore(string("if (")),

      choice([
        Condition.parser(),
        SingleCheck.parser()
      ]),

      ignore(string(")"))
    ])
  end

  def map_command([condition]) do
    %PostfixIf{condition: condition}
  end
end

