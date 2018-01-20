defmodule MacroCompiler.MacroBlock do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression

  def parser() do
    many(
      sequence([
        skip(spaces()),
        choice([
          DoExpression.parser(),
          LogExpression.parser(),
        ]),
        skip(newline())
      ])
    )
  end
end
