defmodule MacroCompiler.SyntaxError do
  use Combine
  use Combine.Helpers
  alias Combine.ParserState

  defexception [:message, :line, :col]

  defparser raiseAtPosition(%ParserState{status: :ok, line: line, column: col} = state) do
    raise MacroCompiler.SyntaxError,
      message: "Syntax error at line #{line}, column #{col}",
      line: line,
      col: col
  end
end
