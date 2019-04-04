defmodule T do

  # separateur
  # <<char, rest :: bitstring>>
  # <<"test">>, rest
  # [{:identifier, "test", %{ length: LENGTH, start: POSITION, end: POSITION } }]

  def parser(str) do
    state = %{ line: 1,
	       position: 0,
	       relative_position: 0,
	       type: :hcl,
	       mode: :default }
    parser(str, <<>>, [], state, [])
  end

  def parser(<<>>, buffer, list, state, opts) do
    {list ++ [buffer], state, opts}
  end
  
  def parser(<<" ", rest :: bitstring>>, <<>>, list, state, opts) do
    parser(rest, <<>>, list, state |> position, opts)
  end

  def parser(<<"\t", rest :: bitstring>>, <<>>, list, state, opts) do
    parser(rest, <<>>, list, state |> position, opts)
  end
  
  def parser(<<" ", rest :: bitstring>>, buffer, list, state, opts) do
    parser(rest, <<>>, list ++ [buffer], state |> position, opts)
  end
  
  def parser(<<"\t", rest :: bitstring>>, buffer, list, state, opts) do
    parser(rest, <<>>, list ++ [buffer], state |> position, opts)
  end
  
  def parser(<<"\n", rest :: bitstring>>, buffer, list, state, opts) do
    parser(rest, <<>>, list ++ [:newline, buffer], state |> line, opts)
  end

  def parser(<<"[", rest :: bitstring>>, buffer, list, state, opts) do
    parser(rest, <<>>, list ++ [:list_open], state |> position, opts)
  end

  def parser(<<"]", rest :: bitstring>>, buffer, list, state, opts) do
    parser(rest, <<>>, list ++ [:list_close], state |> position, opts)
  end

  def parser(<<"{", rest :: bitstring>>, buffer, list, state, opts) do
    parser(rest, <<>>, list ++ [:block_open], state |> position, opts)
  end

  def parser(<<"}", rest :: bitstring>>, buffer, list, state, opts) do
    parser(rest, <<>>, list ++ [:block_close], state |> position, opts)
  end

  def parser(<<"\"", rest :: bitstring>>, buffer, list, %{ mode: {:string, s} } = state, opts) do
    parser(rest, <<>>, list ++ [{:string, buffer, {s, state}}], %{ state | mode: :normal }, opts)
  end
  
  def parser(<<"\"", rest :: bitstring>>, buffer, list, state, opts) do
    string_state = %{ state | mode: {:string, state} }
    parser(rest, <<>>, list, string_state |> position, opts)
  end
  
  def parser(<<char, rest :: bitstring>>, buffer, list, state, opts)
  when char >= 33 and char <= 126 do
    parser(rest, <<buffer :: bitstring, char>>, list, state |> position, opts)
  end

  def parser(<<char, rest :: bitstring>>, buffer, list, state, opts) do
    {:error, {:badchar, state}}
  end
  

  #
  #
  #
  def router(str) do
    router(str, [])
  end
  
  def router(str, opts) do
    state = %{ line: 1,
	       position: 1,
	       relative_position: 1 }
    router(str, <<>>, state, opts)
  end

  def router(<<>>, buffer, state, opts) do
    {buffer, state, opts}
  end

  def router(<<"\n", rest :: bitstring>>, buffer, state, opts) do
    router(rest, <<buffer :: bitstring, "\n">>, state |> line, opts)
  end
  
  def router(<<char :: utf8, rest :: bitstring>>, buffer, state, opts) do
    router(rest, <<buffer :: bitstring, char>>, state |> position, opts)
  end

  #
  #
  #
  def line(%{ line: line, relative_position: relative_position } = state) do
    %{ state |
       line: line+1,
       relative_position: 1 }
  end

  #
  #
  #
  def position(%{ position: position, relative_position: relative_position} = state) do
    %{ state |
       position: position+1,
       relative_position: relative_position+1 }
  end
end
