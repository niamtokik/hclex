defmodule Hclex.LexerTest do
  use ExUnit.Case, async: true

  test "numbers" do
    assert Hclex.Lexer.number("0"),       {:ok, {:number, "0"}}
    assert Hclex.Lexer.number("10"),      {:ok, {:number, "10"}}
    assert Hclex.Lexer.number("-10"),     {:ok, {:number, "-10"}}
    assert Hclex.Lexer.number("9999999"), {:ok, {:number, "9999999"}}
    assert Hclex.Lexer.number("-999999"), {:ok, {:number, "-999999"}}
    assert Hclex.Lexer.number("10.10"),   {:ok, {:number, "10.10"}}
    assert Hclex.Lexer.number("-10.10"),  {:ok, {:number, "-10.10"}}
    assert Hclex.Lexer.number("10e10"),   {:ok, {:number, "10e10"}}
    assert Hclex.Lexer.number("-10e10"),  {:ok, {:number, "-10e10"}}
    assert Hclex.Lexer.number("-10e+10"), {:ok, {:number, "-10e+10"}}
    assert Hclex.Lexer.number("-10e-10"), {:ok, {:number, "-10e-10"}}
    assert Hclex.Lexer.number("10E10"),   {:ok, {:number, "10E10"}}
    assert Hclex.Lexer.number("-10E10"),  {:ok, {:number, "-10E10"}}
    assert Hclex.Lexer.number("-10E+10"), {:ok, {:number, "-10E+10"}}
    assert Hclex.Lexer.number("-10E-10"), {:ok, {:number, "-10E-10"}}
    assert Hclex.Lexer.number("000"), {:error, :badformat}
    assert Hclex.Lexer.number("10ee10", {:error, :badformat}
  end
  
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
