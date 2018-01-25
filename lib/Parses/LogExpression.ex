defmodule MacroCompiler.LogExpression do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ArrayVariable
  alias MacroCompiler.HashVariable

  @enforce_keys [:message]
  defstruct [:message]

  def parser() do
    map(
      sequence([
        ignore(string("log")),
        ignore(spaces()),

        many(
          choice([
            string("\\@"),
            string("\\%"),
            ArrayVariable.parser(),
            HashVariable.parser(),
            if_not(char(?\n), char())
          ])
        ),

        skip(char(?\n))
      ]),
      fn [message] -> %MacroCompiler.LogExpression{message: message} end
    )
  end
end
