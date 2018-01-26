defmodule MacroCompiler do
  use Combine
  alias MacroCompiler.TopLevelBlock
  alias MacroCompiler.SymbolsTable
  alias MacroCompiler.SemanticAnalysis
  alias MacroCompiler.CodeGeneration
  alias MacroCompiler.CodeGenerationHeader

  def start_parser(macro_file) do
    file = File.read!(macro_file)

    try do
      [ast] = Combine.parse(file, TopLevelBlock.parser())
      table = SymbolsTable.build(ast)

      SemanticAnalysis.start_validate(ast, table)

      CodeGenerationHeader.generate(ast, ast, table)
      CodeGeneration.start_generate(ast, ast, table)

    rescue
      e in MacroCompiler.SyntaxError ->
        %MacroCompiler.SyntaxError{col: col, line: line, message: message} = e

        IO.puts IO.ANSI.format([:red, :bright, "#{message}\n"], true)

        file
        |> String.split("\n")
        |> Enum.with_index(1)
        |> Enum.filter(fn {_, index} ->
          index >= line - 2 and index <= line + 2
        end)
        |> Enum.map(fn {lineText, index} ->
          if index == line do
            lineTextSliced0 = String.slice(lineText, 0..(col-1))
            lineTextSliced1 = String.slice(lineText, col..String.length(lineText))

            IO.puts IO.ANSI.format([:bright, "#{index}  -  ", lineTextSliced0, :red,  lineTextSliced1], true)
          else
            IO.puts "#{index}  -  #{lineText}"
          end
        end)

        IO.puts "\n\nMacro couldn't be compiled. Sorry"
    end
  end
end


case System.argv do
  [] -> MacroCompiler.start_parser("macro.txt")
  [macro_file] -> MacroCompiler.start_parser(macro_file)
end
