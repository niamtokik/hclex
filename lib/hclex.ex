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
  defp lstring(<<"\"", r :: bitstring>>, <<>>, opts) do
    lstring(r, <<>>, opts)
  end

  defp lstring(<<"\"", r :: bitstring>>, buffer, opts) do
    {:ok, {:string, buffer}, r}
  end
  
  defp lstring(<<char, r :: bitstring>>, buffer, opts) do
    lstring(r, <<buffer :: bitstring, char>>, opts)
  end



end

defmodule T do

  def l(<<>>, buffer, opts) do
    {:ok, buffer, opts}
  end
  
  def l(<<" ", r :: bitstring>>, buffer, opts) do
    {:ok, buffer, opts}
  end

  def l(<<char, r :: bitstring>>, buffer, opts) do
    l(r, <<buffer :: bitstring, char>>, opts)
  end

  def l(<<char, r :: bitstring>>, buffer, opts) do
    l(r, <<buffer :: bitstring,  char>>, opts)
  end
  
end

defmodule Hclex.Analyzer do
  
end

defmodule Hclex.Translator do
  
end
