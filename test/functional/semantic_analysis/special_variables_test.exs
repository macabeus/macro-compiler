defmodule MacroCompiler.Test.Functional.SemanticAnalysis.SpecialVariables do
  use MacroCompiler.Test.Helper.SemanticAnalysis

  test_should_works(
   "should can read a special variable",
   """
     macro Test {
       log $.zeny
     }
   """
  )

  test_semantic_error(
    "should fail when try to write in a special variable",
    """
      macro Test {
        $.zeny = 1
      }
    """,
    [
      [
        message: [:red, "$.zeny", :default_color, " is a special variable, reassigning is not allowed"],
        metadatas: [%MacroCompiler.Parser.Metadata{ignore: nil, line: 2, offset: 4}]
      ]
    ]
  )
end

