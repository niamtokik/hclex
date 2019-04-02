defmodule Hclex.LexerTest do
  use ExUnit.Case, async: true
  
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
    str = ""
    ret = ""
    assert Hclex.Lexer.lex(str), ret
  end
end
