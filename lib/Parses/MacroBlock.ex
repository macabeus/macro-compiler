defmodule MacroCompiler.MacroBlock do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.SyntaxError

  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression
  alias MacroCompiler.CallExpression
  alias MacroCompiler.UndefScalarVariable
  alias MacroCompiler.ScalarVariableAssignment
  alias MacroCompiler.ArrayVariableAssignment
  alias MacroCompiler.HashVariableAssignment
  alias MacroCompiler.IncrementExpression
  alias MacroCompiler.DecrementExpression
  alias MacroCompiler.PauseExpression
  alias MacroCompiler.PushExpression
  alias MacroCompiler.PopExpression
  alias MacroCompiler.ShiftExpression
  alias MacroCompiler.UnshiftExpression

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
          IncrementExpression.parser(),
          DecrementExpression.parser(),
          PauseExpression.parser(),
          PushExpression.parser(),
          PopExpression.parser(),
          ShiftExpression.parser(),
          UnshiftExpression.parser(),

          SyntaxError.raiseAtPosition(),
        ]),
        skip(newline())
      )
    )
  end
end
