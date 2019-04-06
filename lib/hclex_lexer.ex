defmodule Hclex.Lexer do
  @moduledoc """

  Hclex.Lexer module create an internal representation of a raw HCL or
  HCL+ file. This module ensure every specification of the Hashicorp
  Configuration Language is correctly respected. The IR representation
  is highly descriptive to give enough information about debugging or
  data stream.

  ## Lexer Output Internal Representation (IR)

  ### Optional features

  * Level of tolerance
  * Token filtering
  * HCL only
  * HCL+ only

  ### Token Metadata for Token Internal Representation

  Each token has its own associated metadata containing position
  related information:

  * `line :: non_negative_integer()`: line of the token, compatible
                                      with UNIX (`\n`) and WINDOWS
                                      (`\r\n`) systems.

  * `position :: non_negative_integer()`: position from the beginning
                                          of the file, useful for a
                                          raw datastream.

  * `relative_position :: non_negative_integer()`: relative position
                                                   from the start of
                                                   the a new line

  Those informations are stored in a map.

  ```
  # beginning of the token
  start_ = %{ line: line, 
              position: position, 
              relative_position: relative_position }

  # end of the token
  stop_ = %{ line: line, 
             position: position, 
             relative_position: relative_position }

  # full token metadata representation
  state = % { start: start_, 
            stop: stop_ }
  ```

  ### Comment Token 

  Comments are usually dropped. In our case, comments are really
  useful and can embed documentation or other important
  information.

  ```
  {:comment, comment , state}
  ```

  ### Identifier Token

  * ascii alphabet
  * utf8 alphabet

  ```
  {:identifier, identifier, state}
  ```

  ### String Token

  * alphanumeric characters
  * utf8 characters
  * unicode characters
  * escape character validation

  ```
  {:string, string, state}
  ```

  ### Number Token

  * integers notation
  * float notation
  * scientification notation
  * hexadecimal notation
  * octal notation
  * utf8 notation
  * utf32 notation

  ```
  {:number, number, state}
  ```

  ### List Tokens

  A list is composed of values separated by `,` token.

  ```
  {:list_open, state}
  {:list_separator, state}
  {:list_close, state}
  ```

  ### Block Tokens

  A block token is a composed data structure containing variables

  ```
  {:block_open, state}
  {:block_separator, state}
  {:block_close, state}
  ```

  ### Attribution and HCL+ Tokens

  Attibution token

  ```
  {:equal, state}
  ```

  HCL+ actual tokens
  
  ```
  {:type, state}
  {:type_content, type_content, state}
  {:guard, state}
  {:guard, guard_content, state}
  ```

  ### Full Lexer Internal Representation

  The Internal representation is a list of tuple.

  ### Warnings

  ### Errors


  """

  @type lexer_state :: %{ line: line :: integer(),
			  position: position :: integer(),
			  position_relative: position_relative :: integer()
  }
  @type lexer_state_token :: %{ begin: start :: lexer_state(),
				end: eend :: lexer_state() }
  @type lexer_comment :: {:comment, bitstring(), lexer_state() }
  @type lexer_identifier :: {:identifier, bitstring(), lexer_state() }
  @type lexer_string :: {:string, bitstring(), lexer_state() }
  @type lexer_number :: {:number, bitstring(), lexer_state() }
  @type lexer_list :: {:list_open, lexer_state() } |
                      {:list_close, lexer_state() } |
                      {:list_separator, lexer_state() }
  @type lexer_block :: {:block_open, lexer_state() } | {:bloack_close, lexer_state() }
  @type lexer_return :: [ lexer_comment() | lexer_identifier() | lexer_string() | lexer_number() |
			  lexer_list() | lexer_block(), ... ]
  
  @doc """
  execute the binary string with or without options.
  """
  @spec execute(binary()) :: {:ok, list(), map()}
  def execute(str)do
    execute(str, [])
  end

  @spec execute(binary(), list()) :: {:ok, list(), map()}
  def execute(str, opts) do
    state = %{ line: 1,
	       position: 1,
	       relative_position: 1,
	       version: :hcl }
    router(str, [], state, opts)
  end

  @doc """ 
  Route all the data to the specific HCL data type function.
  """  
  @spec router(binary(), list(), map(), list()) :: {:ok, list(), map()}
  def router(<<>>, buffer, state, opts) do
    {:ok, buffer, state}
  end

  def router(<<"\n", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, line(state), opts)
  end

  def router(<<"\r\n", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, line(state), opts)
  end
  
  def router(<<"#", rest :: bitstring>>, buffer, state, opts) do
    {:ok, comment, rest} = comment_line(rest, opts)
    router(rest, buffer ++ [comment], state, opts)
  end

  def router(<<"//", rest :: bitstring>>, buffer, state, opts) do
    {:ok, comment, r} = comment_line(rest, opts)
    router(r, buffer ++ [comment], state, opts)
  end

  def router(<<"/*", rest :: bitstring>>, buffer, state, opts) do
    {:ok, comment, r} = comment_multiline(rest, opts)
  end
  
  def router(<<" ", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, state, opts)
  end

  def router(<<"\t", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, state, opts)
  end

  def router(<<"\"", rest :: bitstring>>, buffer, state, opts) do
    {:ok, string, r} = string(rest, opts)
    router(r, buffer ++ [string], state, opts)
  end

  def router(<<"=", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:equal], state, opts)
  end

  def router(<<"{", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:block_open], state, opts)
  end

  def router(<<"}", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:block_close], state, opts)
  end

  def router(<<"[", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:list_open], state, opts)
  end

  def router(<<",", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:list_separator], state, opts)
  end
  
  def router(<<"]", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:list_close], state, opts)
  end
  
  def router(<<"<<", rest :: bitstring>>, buffer, state, opts) do
    {:ok, string, r} = string_multiline(rest, opts)
    router(r, buffer ++ [{:string, string}], state, opts)
  end
  
  def router(<<char, rest :: bitstring>>, buffer, state, opts)
  when char >= 48 and char <= 57 do
    {:ok, number, r} = number(<<char, rest :: bitstring>>, opts)
    router(r, buffer ++ [number], state, opts)
  end

  def router(<<char, rest :: bitstring>>, buffer, state, opts)
  when char == 45 do
    {:ok, number, r} = number(<<char, rest :: bitstring>>, opts)
    router(r, buffer ++ [number], state, opts)
  end
      
  def router(<<char :: utf8, rest :: bitstring>>, buffer, state, opts) do
    {:ok, identifier, r} = identifier(<<char, rest :: bitstring>>, opts)
    router(r, buffer ++ [identifier], state, opts)
  end


  @doc """
  Generate and analyze an HCL or HCL+ comment line
  """
  def comment_line(str) do
    comment_line(str, [])
  end
  
  @spec comment_line(binary(), list()) :: {:ok, {:comment, binary()}, binary()}
  def comment_line(str, opts) do
    comment_line(str, <<>>, opts)
  end

  @spec comment_line(binary(), binary(), list()) :: {:ok, {:comment, binary()}, binary()}
  def comment_line(<<>>, buffer, opts) do
    {:ok, {:comment, buffer}, <<>>}
  end

  def comment_line(<<"\r\n", rest :: bitstring>>, buffer, opts) do
    {:ok, {:comment, buffer}, rest}
  end
  
  def comment_line(<<"\n", rest :: bitstring>>, buffer, opts) do
    {:ok, {:comment, buffer}, rest}
  end

  def comment_line(<<char, rest :: bitstring>>, buffer, opts) do
    comment_line(rest, <<buffer :: bitstring, char>>, opts)
  end


  @doc """
  Generate and analyze a multiline comment.
  """
  @spec comment_multiline(binary()) :: {:ok, {:comment, binary()}, binary()}
  def comment_multiline(str) do
    comment_multiline(str, [])
  end

  @spec comment_multiline(binary(), list()) :: {:ok, {:comment, binary()}, binary()}
  def comment_multiline(str, opts) do
    comment_multiline(str, <<>>, opts)
  end

  @spec comment_multiline(binary(), binary(), list()) :: {:ok, {:comment, binary()}, binary()}
  def comment_multiline(<<"*/", rest :: bitstring>>, buffer, opts) do
    {:ok, {:comment, buffer}, rest}
  end
  
  def comment_multiline(<<>>, buffer, opts) do
    {:ok, {:comment, buffer}, <<>>}
  end
  
  def comment_multiline(<<char, rest :: bitstring>>, buffer, opts) do
    comment_multiline(rest, <<buffer :: bitstring, char>>, opts)
  end

  
  @doc """
  Generate and analyze an identifier.
  """
  @spec identifier(binary()) :: {:ok, {:identifier, binary()}, binary()}
  def identifier(str) do
    identifier(str, [])
  end
  
  @spec identifier(binary(), list()) :: {:ok, {:identifier, binary()}, binary()}
  def identifier(str, opts) do
    identifier(str, <<>>, opts)
  end

  @spec identifier(binary(), binary(), list()) :: {:ok, {:identifier, binary()}, binary()}
  def identifier(<<>>, buffer, opts) do
    {:ok, {:identifier, buffer}, <<>>}
  end
  
  def identifier(<<" ", rest :: bitstring>>, buffer, opts) do
    {:ok, {:identifier, buffer}, rest}
  end

  def identifier(<<"\t", rest :: bitstring>>, buffer, opts) do
    {:ok, {:identifier, buffer}, rest}
  end

  def identifier(<<"\n", rest :: bitstring>>, buffer, opts) do
    {:ok, {:identifier, buffer}, rest}
  end

  def identifier(<<"-", rest :: bitstring>>, buffer, opts) do
    identifier(rest, <<buffer :: bitstring, "-">>, opts)
  end

  def identifier(<<"_", rest :: bitstring>>, buffer, opts) do
    identifier(rest, <<buffer :: bitstring, "_">>, opts)
  end
  
  def identifier(<<char, rest :: bitstring>>, buffer, opts)
  when char >= 65 and char <= 90 do
    identifier(rest, <<buffer :: bitstring, char>>, opts)
  end

  def identifier(<<char, rest :: bitstring>>, buffer, opts)
  when char >= 97 and char <= 122 do
    identifier(rest, <<buffer :: bitstring, char>>, opts)
  end
    
  
  @doc """
  Generate and analyze a string.
  """
  def string(str) do
    string(str, [])
  end
  
  @spec string(binary(), list()) :: {:ok, {:string, binary()}, binary()}
  def string(str, opts) do
    string(str, <<>>, opts)
  end

  @spec string(binary(), binary(), list()) :: {:ok, {:string, binary()}, binary()}
  def string(<<"\\\"", rest :: bitstring>>, buffer, opts) do
    string(rest, << buffer :: bitstring, "\\\"">>, opts)
  end
  
  def string(<<"\"", rest :: bitstring>>, buffer, opts) do
    {:ok, {:string, buffer}, rest}
  end
  
  def string(<<char :: utf8, rest :: bitstring>>, buffer, opts) do
    string(rest, <<buffer :: bitstring, char>>, opts)
  end

  @doc """
  Generate multiline string
  """
  def string_multiline(str) do
    string_multiline(str, [])
  end
  
  def string_multiline(str, opts) do
    {:ok, pattern, rest} = string_pattern(str)
    state = %{ pattern: pattern,
	       pattern_size: bit_size(pattern) }
    string_multiline(rest, <<>>, state, opts)
  end

  def string_multiline(str, buffer, state, opts) do
    %{ pattern: pattern, pattern_size: pattern_size } = state
    case str do
      <<"\n", pattern :: size(pattern_size), rest :: bitstring>> -> {:ok, {:string, buffer}, rest}
      <<char, rest :: bitstring>> -> string_multiline(rest, <<buffer :: bitstring, char>>, state, opts)
    end
  end


  @doc """
  Find the multiline string pattern
  """
  def string_pattern(str) do
    string_pattern(str, <<>>)
  end

  def string_pattern(<<"\r\n", rest :: bitstring>>, buffer) do
    {:ok, buffer, rest}
  end
  
  def string_pattern(<<"\n", rest :: bitstring>>, buffer) do
    {:ok, buffer, rest}
  end
  
  def string_pattern(<<char, rest :: bitstring>>, buffer) do
    string_pattern(rest, <<buffer :: bitstring, char>>)
  end
  
  @doc """
  Parse and valid a number. A number can be defined like that:

    * "0": number zero  
    * "0123": octal representation
    * "0x123": hexadecimal representation
    * "123": positive number
    * "-123": negative number
    * ""
    """
  @spec number(binary()) :: {:ok, {:number, binary()}, binary()}
  def number(str) do
    number(str, [])
  end
  
  @spec number(binary(), list()) :: {:ok, {:number, binary()}, binary()}
  def number(str, opts) do
    state = %{ negative: false,
	       scientific: false,
	       float: false,
	       octal: false,
	       hexadecimal: false }
    number(str, <<>>, state, opts)
  end

  @spec number(binary(), binary(), map(), list()) :: {:ok, {:number, binary()}, binary()}  
  def number(<<>>, buffer, state, opts) do
    {:ok, {:number, buffer}, <<>>}
  end

  def number(<<"0x", rest :: bitstring>>, buffer, %{ hexadecimal: false } = state, opts) do
    number(rest, <<"0x">>, %{ state | hexadecimal: true}, opts)
  end
  
  def number(<<"e+", rest :: bitstring>>, buffer, %{ scientific: false } = state, opts) do
    number(rest, <<buffer :: bitstring, "e+">>, %{ state | scientific: true}, opts)
  end

  def number(<<"e-", rest :: bitstring>>, buffer, %{ scientific: false } = state, opts) do
    number(rest, <<buffer :: bitstring, "e-">>, %{ state | scientific: true}, opts)
  end

  def number(<<"E+", rest :: bitstring>>, buffer, %{ scientific: false } = state, opts) do
    number(rest, <<buffer :: bitstring, "E+">>, %{ state | scientific: true}, opts)
  end

  def number(<<"E-", rest :: bitstring>>, buffer, %{ scientific: false } = state, opts) do
    number(rest, <<buffer :: bitstring, "E-">>, %{ state | scientific: true}, opts)
  end

  def number(<<"e", rest :: bitstring>>, buffer, %{ scientific: false } = state, opts) do
    number(rest, <<buffer :: bitstring, "e">>, %{ state | scientific: true}, opts)
  end

  def number(<<"E", rest :: bitstring>>, buffer, %{ scientific: false } = state, opts) do
    number(rest, <<buffer :: bitstring, "E">>, %{ state | scientific: true}, opts)
  end

  def number(<<"-", rest :: bitstring>>, <<>>, %{ negative: false } = state, opts) do
    number(rest, <<"-">>, %{ state | negative: true}, opts)
  end

  def number(<<".", rest :: bitstring>>, buffer, %{ float: false,
						    hexadecimal: false,
						    octal: false } = state, opts) do
    number(rest, <<buffer :: bitstring, ".">>, %{ state | float: true}, opts)
  end

  def number(<<"0", char, rest :: bitstring>>, buffer, %{ octal: false } = state, opts)
  when char >= 48 and char <= 57 do
    number(<<char, rest :: bitstring>>, <<"0">>, %{ state | octal: true}, opts)
  end

  def number(<<char, rest :: bitstring>>, buffer, %{ octal: true } = state, opts)
  when char >= 48 and char <= 55 do
    number(rest, <<buffer :: bitstring, char>>, state, opts)
  end

  def number(<<char, rest :: bitstring>>, buffer, %{ hexadecimal: true } = state, opts)
  when char >= 48 and char <= 57 or char >= 65 and char <= 70 or char >= 97 and char <= 102 do
    number(rest, <<buffer :: bitstring, char>>, state, opts)
  end

  def number(<<char, rest :: bitstring>>, buffer, %{ hexadecimal: false, octal: false } = state, opts)
  when char >= 48 and char <= 57 do
    number(rest, <<buffer :: bitstring, char>>, state, opts)
  end

  def number(<<char, rest :: bitstring>>, buffer, state, opts) do
    {:ok, {:number, buffer}, <<char, rest :: bitstring>>}
  end

  @doc """
  Increment the line by one.
  """
  @spec line(map()) :: map()
  def line(%{ line: line, relative_position: relative_position } = state) do
    %{ state |
       line: line+1,
       relative_position: 1 }
  end

  @doc """
  Increment the cursor position
  """
  def position(%{ position: position, relative_position: relative_position} = state) do
    %{ state |
       position: position+1,
       relative_position: relative_position+1 }
  end
end
