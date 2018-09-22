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
    |> getIndent
    |> mungeLine
    |> tokenizeLine
  end

  def getIndent(%Token{line: line, tokens: tokens} = token) do
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
    if String.length(line) > 0 do
      token
      # munge stuff
      |> ignoreWhitespace
      |> mungeLine
    else
      token
    end
  end

  def ignoreWhitespace(%Token{line: line} = token) do
    %Token{token | line: String.replace(~r/^\s+/, line)}
  end

end