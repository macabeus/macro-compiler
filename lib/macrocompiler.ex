defmodule MacroCompiler do
  use Combine
  alias MacroCompiler.TopLevelBlock

  def start_parser() do
    Combine.parse_file("macro.txt", TopLevelBlock.parser())
  end
end

IO.inspect MacroCompiler.start_parser()
