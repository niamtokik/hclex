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
  Generate and analyze a number.
  """
  @spec number(binary(), list()) :: {:ok, {:number, binary()}, binary()}
  defp number(str, opts) do
    number(str, <<>>, opts)
  end

  @spec number(binary(), binary(), list()) :: {:ok, {:number, binary()}, binary()}
  defp number(<<>>, buffer, opts) do
    {:ok, {:number, buffer}, <<>>}
  end
  
  defp number(<<"-", rest :: bitstring>>, <<>>, opts) do
    number(rest, <<"-">>, opts)
  end
  
  defp number(<<char, rest :: bitstring>>, buffer, opts)
  when char >= 48 and char <= 57 do
    number(rest, <<buffer :: bitstring, char>>, opts)
  end
  
  defp number(<<char, rest :: bitstring>>, buffer, opts) do
    {:ok, {:number, buffer}, rest}
  end

  @doc """
  Increment the line by one.
  """
  @spec line(map()) :: map()
  defp line(state) do
    %{ state | line: state.line+1 }
  end
  
end
