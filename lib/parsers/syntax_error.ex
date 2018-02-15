defmodule MacroCompiler.Parser.SyntaxError do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.SyntaxError
  alias Combine.ParserState

  defexception [:message, :line, :offset]

  defparser raiseAtPosition(%ParserState{status: :ok, line: line, column: col} = state) do
    raise SyntaxError,
      message: "Unknow syntax error",
      line: line,
      offset: col
  end
end
