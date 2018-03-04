defmodule MacroCompiler.Parser.Metadata do
  use Combine
  use Combine.Helpers

  alias Combine.ParserState
  alias MacroCompiler.Parser.Metadata

  @enforce_keys [:line, :offset]
  defstruct [:line, :offset]

  defparser getMetadata(%ParserState{status: :ok, line: line, column: col, results: results} = state) do
    %{state | :results => [%Metadata{line: line, offset: col} | results]}
  end
end
