defmodule Hclex.Lexer do
  @moduledoc """
  Lexer module take a raw HCL or HCL+ string:
  
    * generate a high level view of the raw data
    * analyze the syntax
  
  """

  @doc """
  execute the binary string with or without options.
  """
  @spec execute(binary()) :: {:ok, list(), map()}
  def execute(str)do
    execute(str, [])
  end

  @spec execute(binary(), list()) :: {:ok, list(), map()}
  def execute(str, opts) do
    router(str, [], %{ line: 0 }, opts)
  end
  
  @doc """
  Route all the data to the specific HCL data type function.
  """
  @spec router(binary(), list(), map(), list()) :: {:ok, list(), map()}
  defp router(<<>>, buffer, state, opts) do
    {:ok, buffer, state}
  end

  defp router(<<"\n", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, line(state), opts)
  end

  defp router(<<"\r\n", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, line(state), opts)
  end
  
  defp router(<<"#", rest :: bitstring>>, buffer, state, opts) do
    {:ok, comment, rest} = comment_line(rest, opts)
    router(rest, buffer ++ [comment], state, opts)
  end

  defp router(<<"//", rest :: bitstring>>, buffer, state, opts) do
    {:ok, comment, r} = comment_line(rest, opts)
    router(r, buffer ++ [comment], state, opts)
  end

  defp router(<<"/*", rest :: bitstring>>, buffer, state, opts) do
    {:ok, comment, r} = comment_multiline(rest, opts)
  end
  
  defp router(<<" ", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, state, opts)
  end

  defp router(<<"\t", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, state, opts)
  end

  defp router(<<"\"", rest :: bitstring>>, buffer, state, opts) do
    {:ok, string, r} = string(rest, opts)
    router(r, buffer ++ [string], state, opts)
  end

  defp router(<<"=", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:equal], state, opts)
  end

  defp router(<<"{", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:block_open], state, opts)
  end

  defp router(<<"}", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:block_close], state, opts)
  end

  defp router(<<"<<", rest :: bitstring>>, buffer, state, opts) do
    {:ok, string, r} = string_multiline(rest, opts)
    router(r, buffer ++ [{:string, string}], state, opts)
  end
  
  defp router(<<char, rest :: bitstring>>, buffer, state, opts)
  when char >= 48 and char <= 57 do
    {:ok, number, r} = number(<<char, rest :: bitstring>>, opts)
    router(r, buffer ++ [number], state, opts)
  end

  defp router(<<char, rest :: bitstring>>, buffer, state, opts)
  when char == 45 do
    {:ok, number, r} = number(<<char, rest :: bitstring>>, opts)
    router(r, buffer ++ [number], state, opts)
  end
      
  defp router(<<char :: utf8, rest :: bitstring>>, buffer, state, opts) do
    {:ok, identifier, r} = identifier(<<char, rest :: bitstring>>, opts)
    router(r, buffer ++ [identifier], state, opts)
  end


  @doc """
  Generate and analyze an HCL or HCL+ comment line
  """
  @spec comment_line(binary(), list()) :: {:ok, {:comment, binary()}, binary()}
  defp comment_line(str, opts) do
    comment_line(str, <<>>, opts)
  end

  @spec comment_line(binary(), binary(), list()) :: {:ok, {:comment, binary()}, binary()}
  defp comment_line(<<>>, buffer, opts) do
    {:ok, {:comment, buffer}, <<>>}
  end
  
  defp comment_line(<<"\n", rest :: bitstring>>, buffer, opts) do
    {:ok, {:comment, buffer}, rest}
  end

  defp comment_line(<<"\r\n", rest :: bitstring>>, buffer, opts) do
    {:ok, {:comment, buffer}, rest}
  end

  defp comment_line(<<char, rest :: bitstring>>, buffer, opts) do
    comment_line(rest, <<buffer :: bitstring, char>>, opts)
  end


  @doc """
  Generate and analyze a multiline comment.
  """

  @spec comment_multiline(binary(), list()) :: {:ok, {:comment, binary()}, binary()}
  defp comment_multiline(str, opts) do
    comment_multiline(str, <<>>, opts)
  end

  @spec comment_multiline(binary(), binary(), list()) :: {:ok, {:comment, binary()}, binary()}
  defp comment_multiline(<<>>, buffer, opts) do
    {:ok, {:comment, buffer}, <<>>}
  end
  
  defp comment_multiline(<<"\n", rest :: bitstring>>, buffer, opts) do
    comment_multiline(rest, <<buffer :: bitstring," ">>, opts)
  end
  
  defp comment_multiline(<<"*/", rest :: bitstring>>, buffer, opts) do
    {:ok, {:comment, buffer}, rest}
  end
  
  defp comment_multiline(<<char, rest :: bitstring>>, buffer, opts) do
    comment_multiline(rest, <<buffer :: bitstring, char>>, opts)
  end

  
  @doc """
  Generate and analyze an identifier.
  """
  @spec identifier(binary(), list()) :: {:ok, {:identifier, binary()}, binary()}
  defp identifier(str, opts) do
    identifier(str, <<>>, opts)
  end

  @spec identifier(binary(), binary(), list()) :: {:ok, {:identifier, binary()}, binary()}
  defp identifier(<<>>, buffer, opts) do
    {:ok, {:identifier, buffer}, <<>>}
  end
  
  defp identifier(<<" ", rest :: bitstring>>, buffer, opts) do
    {:ok, {:identifier, buffer}, rest}
  end

  defp identifier(<<"\t", rest :: bitstring>>, buffer, opts) do
    {:ok, {:identifier, buffer}, rest}
  end

  defp identifier(<<"\n", rest :: bitstring>>, buffer, opts) do
    {:ok, {:identifier, buffer}, rest}
  end

  defp identifier(<<"-", rest :: bitstring>>, buffer, opts) do
    identifier(rest, <<buffer :: bitstring, "-">>, opts)
  end

  defp identifier(<<"_", rest :: bitstring>>, buffer, opts) do
    identifier(rest, <<buffer :: bitstring, "_">>, opts)
  end
  
  defp identifier(<<char, rest :: bitstring>>, buffer, opts)
  when char >= 65 and char <= 90 do
    identifier(rest, <<buffer :: bitstring, char>>, opts)
  end

  defp identifier(<<char, rest :: bitstring>>, buffer, opts)
  when char >= 97 and char <= 122 do
    identifier(rest, <<buffer :: bitstring, char>>, opts)
  end
    
  
  @doc """
  Generate and analyze a string.
  """
  @spec string(binary(), list()) :: {:ok, {:string, binary()}, binary()}
  defp string(str, opts) do
    string(str, <<>>, opts)
  end

  @spec string(binary(), binary(), list()) :: {:ok, {:string, binary()}, binary()}
  defp string(<<"\"", rest :: bitstring>>, buffer, opts) do
    {:ok, {:string, buffer}, rest}
  end

  defp string(<<char :: utf8, rest :: bitstring>>, buffer, opts) do
    string(rest, <<buffer :: bitstring, char>>, opts)
  end


  @doc """
  Generate multiline string
  """
  defp string_multiline(str, opts) do
    {:ok, pattern} = string_pattern(str)
    state = %{ pattern: pattern,
	       pattern_size: bit_size(pattern) }
    string_multiline(str, <<>>, state, opts)
  end

  defp string_multiline(str, buffer, state, opts) do
    %{ pattern: pattern, pattern_size: pattern_size } = state
    case str do
      <<pattern :: size(pattern_size), rest :: bitstring>> -> {:ok, {:string, buffer}, rest}
      <<char, rest :: bitstring>> -> string_multiline(rest, <<buffer :: bitstring, char>>, state, opts)
    end
  end


  @doc """
  Find the multiline string pattern
  """
  defp string_pattern(str) do
    string_pattern(str, <<>>)
  end

  defp string_pattern(<<" ">>, buffer) do
    {:ok, buffer}
  end

  defp string_pattern(<<"\t">>, buffer) do
    {:ok, buffer}
  end
  
  defp string_pattern(<<"\n">>, buffer) do
    {:ok, buffer}
  end

  defp string_pattern(<<"\r\n">>, buffer) do
    {:ok, buffer}
  end
  
  defp string_pattern(<<char, rest :: bitstring>>, buffer) do
    string_pattern(rest, <<buffer :: bitstring, char>>)
  end
  
  @doc """
  Generate and analyze a number.
  """
  @spec number(binary(), list()) :: {:ok, {:number, binary()}, binary()}
  defp number(str, opts) do
    state = %{ negative: false,
	       scientific: false,
	       float: false }
    number(str, <<>>, state, opts)
  end

  @spec number(binary(), binary(), map(), list()) :: {:ok, {:number, binary()}, binary()}  
  defp number(<<>>, buffer, state, opts) do
    {:ok, {:number, buffer}, <<>>}
  end

  defp number(<<" ", rest :: bitstring>>, buffer, state, opts) do
    {:ok, {:number, buffer}, rest}
  end

  defp number(<<"\t", rest :: bitstring>>, buffer, state, opts) do
    {:ok, {:number, buffer}, rest}
  end

  defp number(<<"\n", rest :: bitstring>>, buffer, state, opts) do
    {:ok, {:number, buffer}, rest}
  end
  
  defp number(<<"-", rest :: bitstring>>, <<>>, %{ negative: false } = state, opts) do
    number(rest, <<"-">>, %{ state | negative: true}, opts)
  end

  defp number(<<".", rest :: bitstring>>, buffer, %{ float: false } = state, opts) do
    number(rest, <<buffer :: bitstring, ".">>, %{ state | float: true}, opts)
  end
  
  defp number(<<"e+", rest :: bitstring>>, buffer, %{ scientific: false} = state, opts) do
    number(rest, <<buffer :: bitstring, "e+">>, %{ state | scientific: true}, opts)
  end

  defp number(<<"e-", rest :: bitstring>>, buffer, %{ scientific: false} = state, opts) do
    number(rest, <<buffer :: bitstring, "e-">>, %{ state | scientific: true}, opts)
  end

  defp number(<<"E+", rest :: bitstring>>, buffer, %{ scientific: false} = state, opts) do
    number(rest, <<buffer :: bitstring, "e+">>, %{ state | scientific: true}, opts)
  end

  defp number(<<"E-", rest :: bitstring>>, buffer, %{ scientific: false} = state, opts) do
    number(rest, <<buffer :: bitstring, "e-">>, %{ state | scientific: true}, opts)
  end

  defp number(<<"e", rest :: bitstring>>, buffer, %{ scientific: false} = state, opts) do
    number(rest, <<buffer :: bitstring, "e">>, %{ state | scientific: true}, opts)
  end

  defp number(<<"E", rest :: bitstring>>, buffer, %{ scientific: false} = state, opts) do
    number(rest, <<buffer :: bitstring, "e">>, %{ state | scientific: true}, opts)
  end

  defp number(<<char, rest :: bitstring>>, buffer, state, opts)
  when char >= 48 and char <= 57 do
    number(rest, <<buffer :: bitstring, char>>, state, opts)
  end

  @doc """
  Increment the line by one.
  """
  @spec line(map()) :: map()
  defp line(state) do
    %{ state | line: state.line+1 }
  end
  
end
