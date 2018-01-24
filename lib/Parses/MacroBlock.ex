defmodule MacroCompiler.MacroBlock do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression
  alias MacroCompiler.CallExpression
  alias MacroCompiler.UndefScalarVariable
  alias MacroCompiler.ScalarVariableAssignment
  alias MacroCompiler.ArrayVariableAssignment
  alias MacroCompiler.HashVariableAssignment
  alias MacroCompiler.PauseExpression

  def parser() do
    many(
      between(
        spaces(),
        choice([
          DoExpression.parser(),
          LogExpression.parser(),
          CallExpression.parser(),
          UndefScalarVariable.parser(),
          ScalarVariableAssignment.parser(),
          ArrayVariableAssignment.parser(),
          HashVariableAssignment.parser(),
          PauseExpression.parser()
        ]),
        skip(newline())
      )
    )
  end
end
