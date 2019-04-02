defmodule Hclex do
  
  def parse(str) do
    parse(str, [])
  end
    
  def parse(str, opts) do
  end

end

defmodule Hclex.Lexer do
  @doc """
  """
  def lex(str) do
    lex(str, [])
  end

  @doc """
  """
  def lex(str, opts) do
    lexer(str, [], opts)
  end

  @doc """
  """
  defp lexer(<<" ", r :: bitstring>>, buffer, opts) do
    lexer(r, buffer, opts)
  end

  defp lexer(<<"\t", r :: bitstring>>, buffer, opts) do
    lexer(r, buffer, opts)
  end

  defp lexer(<<"\n", r :: bitstring>>, buffer, opts) do
    lexer(r, buffer, opts)
  end

  defp lexer(<<"\r\n", r :: bitstring>>, buffer, opts) do
    lexer(r, buffer, opts)
  end
  
  defp lexer(<<"{", r :: bitstring>>, buffer, opts) do
    lexer(r, buffer ++ :brace_open, opts)
  end

  defp lexer(<<"}", r :: bitstring>>, buffer, opts) do
    lexer(r, buffer ++ :brace_close, opts)
  end

  defp lexer(<<"=", r :: bitstring>>, buffer, opts) do
    lexer(r, buffer ++ :equal, opts)
  end

  defp lexer(<<"\"", r :: bitstring>>, buffer, opts) do
    {:ok, string, rest } = lexer_string(r, opts)
    lexer(rest, buffer <> string, opts)
  end

  defp lexer(<<char, r :: bitstring>>, buffer, opts) do
    lexer(r, buffer <> r, opts)
  end

  defp lexer(<<>>, buffer, otps) do
    {:ok, buffer}
  end
  
  defp lexer(_, buffer, opts) do
    {:error, "wrong data"}
  end


  @doc """
  """
  defp lexer_identifier(str, opts) do
    lexer_identifier(str, <<>>, opts)
  end

  defp lexer_identifier(<<"-", r :: bitstring>>, buffer, opts) do
    lexer_identifier(r, buffer ++ "-", opts)
  end

  defp lexer_identifier(<<"_", r :: bitstring>>, buffer, opts) do
    lexer_identifier(r, buffer ++ "_", opts)
  end

  defp lexer_identifier(<<char, r :: bitstring>>, <<>>, opts)
  when r >= 48 and r <= 57 do
    throw("wrong identifier")
  end

  defp lexer_identifier(<<char, r :: bitstring>>, buffer, opts) do
    lexer_identifier(r, buffer ++ r, opts)
  end

  defp lexer_identifier(<<" ", r :: bitstring>>, buffer, opts) do
    {:ok, {:identifier, buffer}, r}
  end

  defp lexer_identifier(<<"\t", r :: bitstring>>, buffer, opts) do
    {:ok, {:identifier, buffer}, r}
  end

  defp lexer_identifier(<<"\n", r :: bitstring>>, buffer, opts) do
    {:ok, {:identifier, buffer}, r}
  end


  @doc """
  """
  defp lexer_string(str, opts) do
    lexer_string(str, <<>>, opts)
  end
  
  defp lexer_string(<<"\"", r :: bitstring>>, buffer, opts) do
    {:ok, {:string, buffer}, r}
  end

  defp lexer_string(<<x, r :: bitstring>>, buffer, opts) do
    lexer_string(r, buffer <> x, opts)
  end
end
 
defmodule Hclex.Analyzer do
  
end

defmodule Hclex.Translator do
  
end
