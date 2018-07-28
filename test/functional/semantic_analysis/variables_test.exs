defmodule MacroCompiler.Test.Functional.SemanticAnalysis.Variables do
  use MacroCompiler.Test.Helper.SemanticAnalysis

  test_should_works(
    "should can read variables if it was written",
    """
      macro Test {
        $scalar = value
        log $scalar

        @array = ($scalar)
        log @array

        %hash = (key => $scalar)
        log %hash
      }
    """
  )

  test_should_works(
    "should can read variables still that it was written at another macro",
    """
      macro Test {
        log $scalar
      }

      macro SetValue {
        $scalar = value
      }
    """
  )

  test_semantic_warning(
     "should warning when write a variable that was never read",
     """
       macro Test {
         $scalar = value
         @array = ()
         %hash = ()
       }
     """,
     [
       [
         message: ["variable ", :red, "$scalar", :default_color, " is write but it has never read."],
         metadatas: [%MacroCompiler.Parser.Metadata{ignore: nil, line: 2, offset: 4}]
       ],
       [
         message: ["variable ", :red, "%hash", :default_color, " is write but it has never read."],
         metadatas: [%MacroCompiler.Parser.Metadata{ignore: nil, line: 2, offset: 40}]
       ],
       [
         message: ["variable ", :red, "@array", :default_color, " is write but it has never read."],
         metadatas: [%MacroCompiler.Parser.Metadata{ignore: nil, line: 2, offset: 24}]
       ]
     ]
  )

  test_semantic_error(
    "should fail when try to read a variable that has never been written",
    """
      macro Test {
        log $scalar
        log @array if (1)
      }
    """,
    [
      [
        message: ["variable ", :red, "$scalar", :default_color, " is read but it has never been written."],
        metadatas: [%MacroCompiler.Parser.Metadata{ignore: nil, line: 2, offset: 8}]
      ],
      [
        message: ["variable ", :red, "@array", :default_color, " is read but it has never been written."],
        metadatas: [%MacroCompiler.Parser.Metadata{ignore: nil, line: 2, offset: 24}]
      ]
    ]
  )
end

