defmodule Hclex.LexerTest do
  use ExUnit.Case, async: true

  test "simple one line comment (#)" do
    str = "# this is a comment\n"
    ret = [{:comment, " this is a comment"}]
    assert Hclex.Lexer.execute(str), ret
  end

  test "simple one line comment (//)" do
    str = "// this is a comment\n"
    ret = [{:comment, " this is a comment"}]
    assert Hclex.Lexer.execute(str), ret
  end

  test "simple multiline comment (/**/)" do
    str = """
    /* this is a long multiline 
    comment */

    """
    ret = [{:comment, " this is a long multiline comment"}]
    assert Hclex.Lexer.execute(str), ret
  end

  test "simple number" do
    str = "-123.3e10"
    ret = [{:number, "-123.3e10"}]
    assert Hclex.Lexer.execute(str), ret
  end

  test "simple identifier" do
    str = "thisisatest"
    ret = [{:identifier, "thisisatest"}]
    assert Hclex.Lexer.execute(str), ret
  end
  
  test "simple string" do
    str = "\"this is a string\""
    ret = [{:string, "this is a string"}]
    assert Hclex.Lexer.execute(str), ret
  end

  test "simple block" do
    str = """
    { 
       test = 123
    }
    """
    ret = [:block_open, {:identifier, "test"}, :equal, {:number, "123"}, :block_close]
    assert Hclex.Lexer.execute(str), ret
  end

  test "multiline string" do
    str = """
    <<EOF
    test
    EOF
    """
    ret = [{:string, "test"}]
    assert Hclex.Lexer.execute(str), ret
  end

  test "numbers" do
    assert(Hclex.Lexer.execute("0"), [number: "0"])
    assert(Hclex.Lexer.execute("10"), [number: "-10"])
    assert(Hclex.Lexer.execute("-10"), [number: "-10"])
    assert(Hclex.Lexer.execute("9999999"), [number: "9999999"])
    assert(Hclex.Lexer.execute("-999999"), [number: "-999999"])
    assert(Hclex.Lexer.execute("10.10"), [number: "10.10"])
    assert(Hclex.Lexer.execute("-10.10"), [number: "-10.10"])
    assert(Hclex.Lexer.execute("10e10"), [number: "10e10"])
    assert(Hclex.Lexer.execute("-10e10"), [number: "-10e10"])
    assert(Hclex.Lexer.execute("-10e+10"), [number: "-10e+10"])
    assert(Hclex.Lexer.execute("-10e-10"), [number: "-10e-10"])
    assert(Hclex.Lexer.execute("10E10"), [number: "10E10"])
    assert(Hclex.Lexer.execute("-10E10"), [number: "-10E10"])
    assert(Hclex.Lexer.execute("-10E+10"), [number: "-10E+10"])
    assert(Hclex.Lexer.execute("-10E-10"), [number: "-10E-10"])
  end

  test "strings" do
    assert Hclex.lexer.execute("\"this is a test\""), [{:string, "this is a test"}]
  end

end
