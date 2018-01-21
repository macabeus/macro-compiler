defmodule MacroCompiler.MacroBlock do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression
  alias MacroCompiler.CallExpression

  def parser() do
    many(
      between(
        spaces(),
        choice([
          DoExpression.parser(),
          LogExpression.parser(),
          CallExpression.parser()
        ]),
        skip(newline())
      )
    )
  end
end
