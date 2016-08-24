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
    {:ok, _temp_filename } = PdfGenerator.generate @html, [ command_prefix: "env" ]
  end

end
