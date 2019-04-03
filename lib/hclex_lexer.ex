defmodule Hclex.Lexer do
  
  def execute(str)do
    execute(str, [])
  end

  def execute(str, opts) do
    router(str, [], %{}, opts)
  end

  @doc """
  """
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
    comment_line(rest, buffer, state, opts)
  end

  defp router(<<"//", rest :: bitstring>>, buffer, state, opts) do
    comment_line(rest, buffer, state, opts)
  end

  defp router(<<"/*", rest :: bitstring>>, buffer, state, opts) do
    comment_multiline(rest, buffer, state, opts)
  end
  
  defp router(<<" ", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, state, opts)
  end

  defp router(<<"\t", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, state, opts)
  end

  defp router(<<"\"", rest :: bitstring>>, buffer, state, opts) do
    string(rest, buffer, state, opts)
  end

  defp router(<<"=", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer ++ [:equal], state, opts)
  end

  defp router(<<"{", rest :: bitstring>>, buffer, state, opts) do
    block(rest, buffer, state, opts)
  end

  defp router(<<char, rest :: bitstring>>, buffer, state, opts) do
    number(<<char, rest :: bitstring>>, buffer, state, opts)
  end
  
  defp router(<<char :: utf8, rest :: bitstring>>, buffer, state, opts) do
    identifier(<<char :: utf8, rest :: bitstring>>, buffer, state, opts)
  end
  
  defp router(<<char :: utf8, rest :: bitstring>>, buffer, state, opts) do
    {state, opts}
  end


  @doc """
  """
  defp comment_line(<<"\n", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, line(state), opts)
  end
  defp comment_line(<<"\r\n", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, line(state), opts)
  end
  defp comment_line(<<char, rest :: bitstring>>, buffer, state, opts) do
    comment_line(rest, buffer, state, opts)
  end


  @doc """
  """
  defp comment_multiline(<<"\n", rest :: bitstring>>, buffer, state, opts) do
    comment_multiline(rest, buffer, line(state), opts)
  end
  defp comment_multiline(<<"*/", rest :: bitstring>>, buffer, state, opts) do
    router(rest, buffer, state, opts)
  end
  defp comment_multiline(<<char, rest :: bitstring>>, buffer, state, opts) do
    comment_multiline(rest, buffer, state, opts)
  end

  @doc """
  """
  defp identifier(str, buffer, state, opts) do
  end
  
  @doc """
  """
  defp string(str, buffer, state, opts) do
  end

  @doc """
  """
  defp number(str, buffer, state, opts) do
  end

  @doc """
  """
  defp block(str, buffer, state, opts) do
  end

  defp line(state) do
    %{ state | line: state.line+1 }
  end
  
end
