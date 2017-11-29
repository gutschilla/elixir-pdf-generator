defmodule PdfGeneratorTest do
  use ExUnit.Case

  @html "<html><body><h1>Hi</h1><p>Yikes!</p></body></html>"

  test "agent startup" do
    {:ok, _ } = File.stat PdfGenerator.PathAgent.get.wkhtml_path
  end

  test "basic PDF generation" do
    {:ok, temp_filename } = PdfGenerator.generate @html

    # File should exist and has some size
    file_info = File.stat! temp_filename
    assert file_info.size > 0
    pdf = File.read! temp_filename

    # PDF header should be present
    assert String.slice( pdf, 0, 6) == "%PDF-1"
  end

  test "command prefix with noop env" do
    {:ok, _temp_filename } = PdfGenerator.generate @html, command_prefix: "env"
  end

  test "command prefix with args with noop env" do
    {:ok, _temp_filename } = PdfGenerator.generate @html, command_prefix: ["env", "foo=bar"]
  end

  test "generate_binary reads file" do
    assert {:ok, "%PDF-1" <> _pdf} = @html |> PdfGenerator.generate_binary
  end

  test "generate! returns a filename" do
    @html
    |> PdfGenerator.generate!
    |> File.exists?
    |> assert
  end

  test "generate! with filename option returns custom filename" do
    filename = PdfGenerator.generate!(@html, filename: "custom_file_name")
    assert File.exists?(filename)
    assert Path.basename(filename, ".pdf") == "custom_file_name"
  end

  test "generate_binary! reads file" do
    assert "%PDF-1" <> _pdf = @html |> PdfGenerator.generate_binary!
  end

  test "delete_temporary works" do
    # w/o delete_temporary, html should be there
    @html
    |> PdfGenerator.generate!
    |> String.replace( ~r(\.pdf$), ".html")
    |> File.exists?
    |> assert

    # with delete_temporary, html file should be gone
    @html
    |> PdfGenerator.generate!(delete_temporary: true)
    |> String.replace( ~r(\.pdf$), ".html")
    |> File.exists?
    |> refute

    # cannot really be sure if temporyr file was deleted but this shouldn't
    # crash at least. We could scan the temp dir before and after but had to
    # make sure no other process wrote something in there which isn't exactly
    # robust.
    assert {:ok, "%PDF-1" <> _pdf} = @html |> PdfGenerator.generate_binary(delete_temporary: true)
  end

end
