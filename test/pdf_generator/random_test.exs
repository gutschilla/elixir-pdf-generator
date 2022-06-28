defmodule PdfGenerator.RandomTest do
  use ExUnit.Case

  describe "string/0" do
    test "returns an 8 length random string" do
      string = PdfGenerator.Random.string()
      assert String.valid?(string)
      assert String.length(string) == 8
    end
  end

  describe "string/1" do
    test "returns a random string with the given length" do
      string = PdfGenerator.Random.string(99)
      assert String.valid?(string)
      assert String.length(string) == 99
    end
  end
end
