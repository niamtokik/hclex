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
    with UNIX (`\\n`) and WINDOWS (`\\r\\n`) systems.

  * `position :: non_negative_integer()`: position from the beginning
    of the file, useful for a raw datastream.

  * `relative_position :: non_negative_integer()`: relative position
     from the start of the a new line

  * `version :: atom()`: contain the version of file. support `:hcl`
    and `:hclplus` version

  Those informations are stored in a map.

  ``` elixir
  # beginning of the token
  start_ = %{ line: line, 
              position: position, 
              relative_position: relative_position,
	      version: :hcl }

  # end of the token
  stop_ = %{ line: line, 
             position: position, 
             relative_position: relative_position,
	     version: :hcl }

  # full token metadata representation
  state = % { start: start_, 
              stop: stop_ }
  ```

  ### Comment Token 

  Comment data-structure is a triplet, the first element is a fixed
  atom `:comment`, the second element is the raw string containing the
  comment, the third element is the associated metadata of the comment.

  Comments are usually dropped. In our case, comments are really
  useful and can embed documentation or other important
  information.

  A comment is defined in 2 ways:

    * single line comment: any characters after `#` and `//`
    * multi line comment: any characters between `/*` and `*/`

  A comment can store any kind of characters.

  Here some comments example:

  ```txt
  # this is a comment

  // this is another comment

  /* this is a multi line
     comment /*
  ```

  And the produced data-structure:

  ```elixir
  {:comment, comment, state}
  ```

  ### Identifier Token

  Identifier data-structure is a triplet. The first element is a fixed
  atom `:identifier`, the second element is a raw string containing
  the name of the identifier. The third element is the identifier
  metadata containing the information about the identifier.

  An identifier is a term containing only alphanumeric numbers and
  supporting ascii/utf8 alphabet.

  Here an identifier example:

  ```txt
  an_identifier123
  ```

  And here the output:

  ```elixir
  {:identifier, identifier, state}
  ```

  ### String Token

  String data-structure is a triplet. The first element is a fixed
  atom `:string`. The second element is a raw string containing the
  content of the string. The third element is the string metadata.

  A string start by `"` (double quote) character and end with `"`
  (double quote) character. A string can contain any alphanumeric
  characters and escaped sequence.

  A multiline string exist too. Any character present between
  `<<PATTERN\n` and `PATTERN\n` are converted as string where
  `PATTERN` is a range of characters.

  Here some string example:

  ```txt
  "i am a string"

  <<EOF
  i am a multiline string
  EOF
  ```

  and here the output:

  ```elixir
  {:string, string, state}
  ```

  ### Number Token

  Number data-structure is a triplet. The first element is a fixed
  atom `:number`. The second element is a raw string containing the
  content of the number. The third element is the metadata of the
  number.

  A number can have multiple representation:
  
    * integers notation (e.g. `123`)
    * float notation (e.g. `123.123`)
    * scientific notation (e.g. `123.10e10`)
    * hexadecimal notation (e.g. `0x123`)
    * octal notation (e.g. `\0213`)
    * utf8 notation (e.g. `\u1234`)
    * utf32 notation (e.g. `\U1234`)

  Here a number example:

  ```txt
  123456789.10
  ```

  And the resulting output:

  ```elixir
  {:number, number, state}
  ```

  ### List Tokens

  Lists data-structures are triplets. The first element is an atom
  `:list`. The second element is an atom and represent the character,
  `:open` for `[`, `:separator` for `,` and `:close` for `]`. The
  third element is the metadata.

  A list is a composed data-structure and can contain string and
  number in it.

  Here a list example:

  ```txt
  [1,2,3,"test"]
  ```

  And the result:

  ```
  {:list, :open, state}
  {:list, :separator, state}
  {:list, :close, state}
  ```

  ### Block Tokens

  Block data-structure is a triplet. The first element is an atom
  `:block`. The second element contains different atoms, `:open` for
  `{`, `:separator` for `\n` and `:close` for `}`. The third element
  contain the metadata.

  A block token is a composed data structure containing variables (as
  identifier) and content of the variables (as string, numbers, lists
  or blocks).

  Here an example of block:

  ```txt
  { 
    identifier = "string"
  }
  ```

  Here the data-struture output:

  ```elixir
  {:block, :open, state}
  {:block, :separator, state}
  {:block, :attribution, state}
  {:block, :close, state}
  ```

  ### Type Token (HCL+)

  A type is a data-structure giving the possibility to check the
  content of a pattern based on different method like regex.
  
  Here an example

  ```txt
  identifier :: type()
  ```

  and here the data-structure produced

  ```elixir
  {:type, type, state}
  ```

  ### Guard Token (HCL+)

  A guard is a data-structure giving the possibility to check the
  content of a pattern based on external functions and remotely fixed
  values (think it as a database with pattern in it)
  
  Here an example:
  
  ```txt
  identifier !! guard()
  ```

  And here the data-structure produced

  ```elixir
  {:guard, guard, state}
  ```

  ### Full Lexer Internal Representation

  The full IR is a list composed of tuple. 

  ### Warnings

  ### Errors


  """

  @type raw_string() :: bitstring()
  @type position() :: integer()
  @type position_relative() :: integer()
  @type line() :: integer()
  @type version() :: atom()
  @type lexer_opts() :: list()
  
  @type lexer_state :: %{ line: line :: integer(),
			  position: position :: integer(),
			  position_relative: position_relative :: integer(),
			  version: version :: version()
			  
  }
  @type lexer_state_start() :: lexer_state()
  @type lexer_state_stop() :: lexer_state()
  
  @type lexer_state_token :: %{ start: start :: lexer_state_start(),
				stop: stop :: lexer_state_stop() }
  
  @type lexer_comment :: { :comment :: atom(),
			   comment :: bitstring(),
			   state :: lexer_state() }
  
  @type lexer_identifier :: {:identifier :: atom(),
			     comment :: bitstring(),
			     state :: lexer_state() }
  
  @type lexer_string :: {:string :: atom(),
			 string :: bitstring(),
			 state :: lexer_state() }
  
  @type lexer_number :: {:number :: atom(),
			 number :: bitstring(),
			 state :: lexer_state() }

  @type lexer_list :: {:list :: atom(), :open :: atom(), state :: lexer_state() } |
                      {:list :: atom(), :close :: atom(), state :: lexer_state() } |
                      {:list :: atom(), :separator :: atom(), state :: lexer_state() }
  
  @type lexer_block :: {:block :: atom(), :open :: atom(), state :: lexer_state() } |
                       {:block :: atom(), :close :: atom(), state :: lexer_state() }
  
  @type lexer_equal :: {:separator :: atom(), :equal :: atom(), state :: lexer_state() }
  
  @type lexer_return :: [ lexer_comment() | lexer_identifier() | lexer_string() | lexer_number() |
			  lexer_list() | lexer_block(), ... ]
  
  @doc """
  `execute/1` take a bitstring and split it in token.
  """
  @spec execute(raw_string :: raw_string()) :: {:ok, lexer_return(), lexer_state()}
  def execute(str)do
    execute(str, [])
  end

  
  @doc """
  `execute/2` take a bitstring and split it in token. The second
  argument can alter the behavior of the lexer.
  """  
  @spec execute(raw_string :: raw_string(),
                opts :: list()) :: {:ok, lexer_return(), lexer_state()}
  def execute(str, opts) do
    state = %{ line: 1,
	       position: 1,
	       position_relative: 1,
	       version: :hcl }
    router(str, [], state, opts)
  end

  @doc """ 
  `router/4` is the main lexer fsm by splitting the raw string in
  token. This function should be private and only accessible by
  `execute/1` and `execute/2` functions.
  """  
  @spec router(raw_string :: raw_string(), ret :: lexer_return(), state :: lexer_state(), opts :: list()) :: {:ok, lexer_return(), lexer_state()}
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
  @spec comment_line(raw_string :: raw_string()) :: {:ok, comment :: lexer_comment(), rest :: raw_string() }
  def comment_line(str) do
    comment_line(str, [])
  end

  @spec comment_line(raw_string :: raw_string(), opts :: lexer_opts()) :: {:ok, comment :: lexer_comment(), rest :: raw_string() }
  def comment_line(str, opts) do
    comment_line(str, <<>>, opts)
  end

  @spec comment_line(raw_string :: raw_string(), raw_string :: raw_string(), opts :: lexer_opts()) :: {:ok, comment :: lexer_comment(), rest :: raw_string() }
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
  def line(%{ line: line, position_relative: relative_position } = state) do
    %{ state |
       line: line+1,
       position_relative: 1 }
  end

  @doc """
  Increment the position and position_relative cursors
  """
  @spec position(map()) :: map()
  def position(%{ position: position, position_relative: relative_position} = state) do
    %{ state |
       position: position+1,
       position_relative: relative_position+1 }
  end
end
