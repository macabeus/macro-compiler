defmodule MacroCompiler.Test.Functional.SemanticAnalysis.Call do
  use MacroCompiler.Test.Helper.SemanticAnalysis

  test_should_works(
    "should can call a macro",
    """
      macro Test {
        call ShouldCall
      }

      macro ShouldCall {
      }
    """
  )

  test_semantic_error(
    "should fail when try to call an unknown macro",
    """
      macro Test {
        call UnknownMacro
      }
    """,
    [
      [
        message: ["macro ", :red, "UnknownMacro", :default_color, " is called but it has never been written."],
        metadatas: [%MacroCompiler.Parser.Metadata{ignore: nil, line: 2, offset: 4}]
      ]
    ]
  )
end

