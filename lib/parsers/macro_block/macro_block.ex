defmodule MacroCompiler.Parser.MacroBlock do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.SyntaxError

  alias MacroCompiler.Parser.DoCommand
  alias MacroCompiler.Parser.LogCommand
  alias MacroCompiler.Parser.CallCommand
  alias MacroCompiler.Parser.UndefCommand
  alias MacroCompiler.Parser.ScalarAssignmentCommand
  alias MacroCompiler.Parser.ArrayAssignmentCommand
  alias MacroCompiler.Parser.HashAssignmentCommand
  alias MacroCompiler.Parser.IncrementCommand
  alias MacroCompiler.Parser.DecrementCommand
  alias MacroCompiler.Parser.PauseCommand
  alias MacroCompiler.Parser.PushCommand
  alias MacroCompiler.Parser.PopCommand
  alias MacroCompiler.Parser.ShiftCommand
  alias MacroCompiler.Parser.UnshiftCommand
  alias MacroCompiler.Parser.Comment
  alias MacroCompiler.Parser.DeleteCommand
  alias MacroCompiler.Parser.KeysCommand

  def parser() do
    many(
      map(
       sequence([
         between(
           skip(spaces()),
           choice([
             ignore(Comment.parser()),

             DoCommand.parser(),
             LogCommand.parser(),
             CallCommand.parser(),
             UndefCommand.parser(),
             ScalarAssignmentCommand.parser(),
             ArrayAssignmentCommand.parser(),
             HashAssignmentCommand.parser(),
             IncrementCommand.parser(),
             DecrementCommand.parser(),
             PauseCommand.parser(),
             PushCommand.parser(),
             PopCommand.parser(),
             ShiftCommand.parser(),
             UnshiftCommand.parser(),
             DeleteCommand.parser(),
             KeysCommand.parser(),

             # If we could not understand the command in this line, and it's not a close-braces,
             # then it's a syntax error
             if_not(char(?}), SyntaxError.raiseAtPosition()),
           ]),
           skip(newline())
        ),
      ]),

      fn [node] ->
        node
      end)
    )
  end
end
