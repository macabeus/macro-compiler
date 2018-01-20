defmodule MacroCompiler.MacroBlock do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.DoExpression

  def parser() do
    many(
      sequence([
        skip(spaces()),
        DoExpression.parser(),
        skip(newline())
      ])
    )
  end
end
