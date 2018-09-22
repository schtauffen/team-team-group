defmodule TeamTeamGroup.Tokenizor do
  alias TeamTeamGroup.Token

  def tokenizeLine(%Token{tokens: tokens, lines: lines, line: line} = token) do
    if length(lines) > 0 do
      [line | lines] = lines
      tokenizor %Token{token | line: line, lines: lines}
    else
      tokens
    end 
  end

  def tokenizor(%Token{line: line} = token) do
    token
    |> getindent
    |> mungeLine
    |> tokenizeLine
  end

  def getindent(%Token{line: line, tokens: tokens} = token) do
    %{"rest" => rest, "whitespace" => whitespace} = ~r/^(?<whitespace>\s*)(?<rest>.*)$/
    |> Regex.named_captures(line)

    if String.length(whitespace) > 0 && String.length(rest) > 0 do
      indent = %{type: :indent, value: String.length(whitespace) }
      %Token{token | tokens: tokens ++ [indent], line: rest}
    else
      token
    end
  end

  def mungeLine(%Token{line: line, tokens: tokens} = token) do
    orig_len = String.length(line)
    if orig_len > 0 do
      new_token = token
      # munge stuff
      |> numbertoken
      |> stringtoken
      |> nametoken
      |> ignoreWhitespace

      %Token{line: new_line} = new_token

      if String.length(new_line) == orig_len do
        nil # figure out better error handling
      else
        mungeLine(new_token)
      end
    else
      eol = %{type: :eol, value: nil}
      %Token{token | tokens: tokens ++ [eol] }
    end
  end

  def numbertoken(%Token{line: line, tokens: tokens} = token) do
    # TODO - decimal
    %{"rest" => rest, "num" => num} = ~r/^(?<num>[0-9]*)\s*(?<rest>.*)$/
    |> Regex.named_captures(line)

    if String.length(num) > 0 do
      number = %{type: :number, value: num}
      %Token{token | line: rest, tokens: tokens ++ [number]}
    else
      token
    end
  end

  def stringtoken(%Token{line: line, tokens: tokens} = token) do
    %{"rest" => rest, "str" => str} = ~r/^(?<str>"[^"]*")?\s*(?<rest>.*)$/
    |> Regex.named_captures(line)

    if String.length(str) > 0 do
      string = %{type: :string, value: str}
      %Token{token | line: rest, tokens: tokens ++ [string]}
    else
      token
    end
  end

  def nametoken(%Token{line: line, tokens: tokens} = token) do
    %{"rest" => rest, "name" => name} = ~r/^(?<name>[a-z]*)\s*(?<rest>.*)$/
    |> Regex.named_captures(line)

    if String.length(name) > 0 do
      nom = %{type: :name, value: name}
      %Token{token | line: rest, tokens: tokens ++ [nom]}
    else
      token
    end
  end

  def ignoreWhitespace(%Token{line: line} = token) do
    %Token{token | line: String.replace(line, ~r/^\s+/, "")}
  end

end