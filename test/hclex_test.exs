defmodule Hclex.LexerNumberTest do
  use ExUnit.Case, async: true

  test "0" do
    assert Hclex.Lexer.number("0") == {:ok, {:number, "0"}, ""}
  end

  test "positive decimal integers" do
    assert Hclex.Lexer.number("10") == {:ok, {:number, "10"}, ""}
    assert Hclex.Lexer.number("9999999999") == {:ok, {:number, "9999999999"}, ""}
    assert Hclex.Lexer.number("1234567890") == {:ok, {:number, "1234567890"}, ""}
  end

  test "negative decimal integers" do
    assert Hclex.Lexer.number("-10") == {:ok, {:number, "-10"}, ""}
  end

  test "positive floats" do
    assert Hclex.Lexer.number("0.123") == {:ok, {:number, "0.123"}, ""}
    assert Hclex.Lexer.number("10.123") == {:ok, {:number, "10.123"}, ""}
    assert Hclex.Lexer.number("123.456789") == {:ok, {:number, "123.456789"}, ""}
    assert Hclex.Lexer.number("999999.999") == {:ok, {:number, "999999.999"}, ""}
    assert Hclex.Lexer.number("3.14") == {:ok, {:number, "3.14"}, ""}
  end

  test "negative floats" do
    assert Hclex.Lexer.number("-0.123") == {:ok, {:number, "-0.123"}, ""}
    assert Hclex.Lexer.number("-10.123") == {:ok, {:number, "-10.123"}, ""}
    assert Hclex.Lexer.number("-123.456789") == {:ok, {:number, "-123.456789"}, ""}
    assert Hclex.Lexer.number("-999999.999") == {:ok, {:number, "-999999.999"}, ""}
    assert Hclex.Lexer.number("-3.14") == {:ok, {:number, "-3.14"}, ""}
  end

  test "positive scientific numbers" do
    assert Hclex.Lexer.number("3e10") == {:ok, {:number, "3e10"}, ""}
    assert Hclex.Lexer.number("123e456789") == {:ok, {:number, "123e456789"}, ""}
    assert Hclex.Lexer.number("123.456e789") == {:ok, {:number, "123.456e789"}, ""}
    assert Hclex.Lexer.number("123.456E789") == {:ok, {:number, "123.456E789"}, ""}
    assert Hclex.Lexer.number("123.456e+789") == {:ok, {:number, "123.456e+789"}, ""}
    assert Hclex.Lexer.number("123.456e-789") == {:ok, {:number, "123.456e-789"}, ""}
    assert Hclex.Lexer.number("123.456E+789") == {:ok, {:number, "123.456E+789"}, ""}
    assert Hclex.Lexer.number("123.456E-789") == {:ok, {:number, "123.456E-789"}, ""}
  end

  test "negative scientific numbers" do
    assert Hclex.Lexer.number("-3e10") == {:ok, {:number, "-3e10"}, ""}
    assert Hclex.Lexer.number("-123e456789") == {:ok, {:number, "-123e456789"}, ""}
    assert Hclex.Lexer.number("-123.456e789") == {:ok, {:number, "-123.456e789"}, ""}
    assert Hclex.Lexer.number("-123.456e-789") == {:ok, {:number, "-123.456e-789"}, ""}
    assert Hclex.Lexer.number("-123.456e+789") == {:ok, {:number, "-123.456e+789"}, ""}
    assert Hclex.Lexer.number("-123.456E-789") == {:ok, {:number, "-123.456E-789"}, ""}
    assert Hclex.Lexer.number("-123.456E+789") == {:ok, {:number, "-123.456E+789"}, ""}
  end

  test "octal number representation" do
    assert Hclex.Lexer.number("01234567") == {:ok, {:number, "01234567"}, ""}
    assert Hclex.Lexer.number("07654321") == {:ok, {:number, "07654321"}, ""}
  end
  
  test "hexadecimal numbers representation" do
    assert Hclex.Lexer.number("0x123") == {:ok, {:number, "0x123"}, ""}
    assert Hclex.Lexer.number("0x123456789") == {:ok, {:number, "0x123456789"}, ""}
    assert Hclex.Lexer.number("0xabcdef") == {:ok, {:number, "0xabcdef"}, ""}
    assert Hclex.Lexer.number("0x123abc456def") == {:ok, {:number, "0x123abc456def"}, ""}
    assert Hclex.Lexer.number("0xABCDEF") == {:ok, {:number, "0xABCDEF"}, ""}
    assert Hclex.Lexer.number("0x123ABC456DEF") == {:ok, {:number, "0x123ABC456DEF"}, ""}
  end
end

defmodule Hclex.LexerCommentTest do
  use ExUnit.Case, async: true

  test "one line comment test (#)" do
    assert Hclex.Lexer.comment_line("its a comment\ntest") == {:ok, {:comment, "its a comment"}, "test"}
  end

  test "one line comment test (//)" do
    assert Hclex.Lexer.comment_line("its a comment\ntest") == {:ok, {:comment, "its a comment"}, "test"}
  end

  test "multiline comment test (/**/)" do
    str = """
    this is a multiline
    comment */ test
    """
    ret = {:ok, {:comment, "this is a multiline\ncomment "}, " test\n"}
    assert Hclex.Lexer.comment_multiline(str) == ret    
  end
end

defmodule Hclex.LexerStringTest do
  use ExUnit.Case, async: true

  test "simple string" do
    assert Hclex.Lexer.string("this is a string\"") == {:ok, {:string, "this is a string"}, ""}
  end

  test "multiline string" do
    str = """
    EOF
    test
    EOF
    """
    assert Hclex.Lexer.string_multiline(str) == {:ok, {:string, "test"}, "\n"}
  end
  
end

defmodule Hclex.LexerIdentifierTest do
  use ExUnit.Case, async: true

  test "identifier" do
    assert Hclex.Lexer.identifier("test") == {:ok, {:identifier, "test"}, ""}
    assert Hclex.Lexer.identifier("_test") == {:ok, {:identifier, "_test"}, ""}
    assert Hclex.Lexer.identifier("Test") == {:ok, {:identifier, "Test"}, ""}
  end
end

defmodule Hclex.LexerListTest do
  use ExUnit.Case, async: true

  test "empty list with space" do
    str = "[ ]"
    {:ok, ret, _state} = Hclex.Lexer.execute(str)
    assert ret == [:list_open, :list_close]
  end

  test "empty list" do
    str = "[]"
    {:ok, ret, _state} = Hclex.Lexer.execute(str)
    assert ret == [:list_open, :list_close]
  end

  test "list with number" do
    str = "[1,2,3]"
    {:ok, ret, _state} = Hclex.Lexer.execute(str)
    assert ret == [:list_open,
		   {:number, "1"}, :list_separator,
		   {:number, "2"}, :list_separator,
		   {:number, "3"}, :list_close]
  end

  test "list with strings" do
    str = "[\"test\",\"test2\"]"
    {:ok, ret, _state} = Hclex.Lexer.execute(str)
    assert ret == [:list_open,
		   {:string, "test"}, :list_separator,
		   {:string, "test2"}, :list_close]
  end

  test "list with strings and numbers" do
    str = "[1,\"test\",2,\"test2\"]"
    {:ok, ret, _state} = Hclex.Lexer.execute(str)
    assert ret == [:list_open,
		   {:number, "1"}, :list_separator,
		   {:string, "test"}, :list_separator,
		   {:number, "2"}, :list_separator,
		   {:string, "test2"}, :list_close]
  end
  
end

defmodule Hclex.LexerBlockTest do
  use ExUnit.Case, async: true

  test "block" do
    str = "{ }"
    {:ok, ret, _state} = Hclex.Lexer.execute(str)
    assert ret == [:block_open, :block_close]
  end

  test "empty block" do
    str = "{}"
    {:ok, ret, _state} = Hclex.Lexer.execute(str)
    assert ret == [:block_open, :block_close]
  end
end

defmodule Hclex.LexerTest do
  use ExUnit.Case, async: true

  test "block with attribution" do
    str = """
    { 
      identifier = "value"
    }
    """
    {:ok, ret, _state} = Hclex.Lexer.execute(str)
    assert ret == [:block_open, {:identifier, "identifier"}, :equal, {:string, "value"}, :block_close]
  end

  test "block with list" do
    str = """
    { 
      identifier = [1,2,3]
    }
    """
    {:ok, ret, _state} = Hclex.Lexer.execute(str)
    
    assert ret = [:block_open, {:identifier, "identifier"}, :equal,
                  :list_open, {:number, "1"}, :list_separator,
		  {:number, "2"}, :list_separator,
		  {:number, "3"}, :list_close, :block_close]
		    
		  
  end
  
end
