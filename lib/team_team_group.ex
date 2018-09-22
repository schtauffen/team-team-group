defmodule TeamTeamGroup do
  alias TeamTeamGroup.Token
  alias TeamTeamGroup.Tokenizor

  def compile(filename) do
    case File.read filename do
      {:ok, body} ->
        Tokenizor.tokenizeLine(%Token{lines: String.split(body, "\n")})
      {:error, err} ->
        err
    end
  end

end
