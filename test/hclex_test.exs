defmodule Hclex.LexerTest do
  use ExUnit.Case, async: true

  test "comment #" do
    str = "# this is a comment"
    ret = [{:comment, "this is a comment"}]
    assert Hclex.Lexer.lex(str), ret
  end

  test "comment //" do
    str = "// this is a comment"
    ret = [{:comment, "this is a comment"}]
    assert Hclex.Lexer.lex(str), ret
  end

  test "comment /**/" do
    str = "/* this is a comment */"
    ret = [{:comment, "this is a comment"}]
    assert Hclex.Lexer.lex(str), ret
  end
  
  test "simple identifier" do
    str = "test"
    ret = [{:identifier, "test"}]
    assert Hclex.Lexer.lex(str), ret
  end

  test "simple string" do
    str = "\"this is a string\""
    ret = [{:string, "this is a string"}]
    assert Hclex.Lexer.lex(str), ret
  end

  test "simple number" do
    str = "1234"
    ret = [{:number, 1234}]
    assert Hclex.Lexer.lex(str), ret
  end

  test "simple attributes" do
    str = "identifier = 1234"
    ret = [{:identifier, "identifier"}, :equal, {:number, 1234}]
    assert Hclex.Lexer.lex(str), ret
  end

  test "simple block" do
    str = """
    resource "test" {
      identifier = "test"
    }
    """    
    ret = [{:identifier, "resource"}, {:string, "test"}, :brace_open,
           {:identifier, "identifier"}, :equal, {:string, "test"}]
    
    assert Hclex.Lexer.lex(str), ret
  end
end
