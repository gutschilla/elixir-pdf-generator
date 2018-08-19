defmodule PdfGenerator.Random do
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" |> String.codepoints()

  def string(length \\ 8) do
    Enum.map_join(1..length, fn _ -> Enum.random(@chars) end)
  end
end
