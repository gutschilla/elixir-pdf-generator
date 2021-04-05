defmodule PdfGenerator.Random do
  @moduledoc """
  Helper function for random string generator.
  """

  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" |> String.codepoints()

  @doc """
  Generate random string by length.
  """
  def string(length \\ 8) do
    Enum.map_join(1..length, fn _ -> Enum.random(@chars) end)
  end
end
