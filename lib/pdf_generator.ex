defmodule PdfGenerator do

  @vsn "0.2.0"

  @moduledoc """
  # PdfGenerator

  Provides a simple wrapper around [wkhtmltopdf](http://wkhtmltopdf.org) and
  [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) to generate
  possibly encrypted PDFs from an HTML source. 

  # System requirements

  - wkhtmltopdf
  - pdftk (optional, for encrypted PDFs)
  - goon (optional, for Porcelain shalle wrapper)

  Precompiled **wkhtmltopdf** binaries can be obtained here:
  http://wkhtmltopdf.org/downloads.html

  **pdftk** should be available as package on your system via
   
   - `apt-get install pdftk` on Debian/Ubuntu
   - `brew pdftk` on OSX (you'll need homebrew, of course)
   - Install the Exe-Installer on Windows found the project's homepage (link
   above)

  **goon** is available here:
  https://github.com/alco/goon/releases

  """

  use Application
  alias Porcelain.Result
  alias Misc.Random

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
      import Supervisor.Spec, warn: false

      children = [
        # Define workers and child supervisors to be supervised
        # worker(TestApp.Worker, [arg1, arg2, arg3])
      ]

      opts = [strategy: :one_for_one, name: PdfGenerator.Supervisor]
      Supervisor.start_link(children, opts)
  end

  # return file name of generated pdf
  # requires: Porcelain, Random
  @doc """
  Generates a pdf file from given html string. Returns a string containing a
  temporary file path for that PDF. 

  options:

   - page_size: output page size, defaults to "A4"
   - open_password: password required to open PDF. Will apply encryption to PDF
   - edit_password: password required to edit PDF
   - shell_params: list of command-line arguments to wkhtmltopdf
     see http://wkhtmltopdf.org/usage/wkhtmltopdf.txt for all options

  # Examples

  pdf_path_1 = PdfGenerator.generate "<html><body><h1>Boom</h1></body></html>"
  pdf_path_2 = PdfGenerator.generate(
    "<html><body><h1>Boom</h1></body></html>", 
    page_size:     "A5",
    open_password: "secret",
    edit_password: "g3h31m",
    shell_params: [ "--outline", "--outline-depth3", "3" ]
  )
  """
  def generate( html ) do
    generate html, page_size: "A4"
  end

  def generate( html, options ) do
    wkhtml_path = System.find_executable("wkhtmltopdf")
    if wkhtml_path == nil, do: raise "Cannot find wkhtmltopdf in path. See http://wkhtmltopdf.org"
    html_file = Path.join System.tmp_dir, Random.string <> ".html"
    File.write html_file, html
    pdf_file  = Path.join System.tmp_dir, Random.string <> ".pdf"

    shell_params = [ 
      "--page-size", Keyword.get( options, :page_size ) || "A4",
      Keyword.get( options, :shell_params ) || [] # will be flattened
    ]

    %Result{ out: _output, status: status } = Porcelain.exec(
      wkhtml_path, List.flatten( [ shell_params, html_file, pdf_file ] )
    )

    case status do
      0 -> 
        case Keyword.get options, :open_password do
          nil     -> { :ok, pdf_file }
          user_pw -> encrypt_pdf( 
            pdf_file, 
            user_pw, 
            Keyword.get( options, :edit_password ) 
          )
        end
      _ -> { :error, "wkhtmltopdf returned with nonzero vaule. This is likely du to bad shell_params" }
    end
  end

  def encrypt_pdf( pdf_input_path, user_pw, owner_pw ) do
    pdftk_path = System.find_executable "pdftk"
    if pdftk_path == nil, do: raise "Cannot find pdftk in path. See https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/"

    if owner_pw == nil, do: owner_pw = Random.string(16)
    if user_pw  == nil, do: user_pw  = Random.string(16)

    pdf_output_file  = Path.join System.tmp_dir, Random.string <> ".pdf"

    %Result{ out: _output, status: status } = Porcelain.exec(
      pdftk_path, [ 
        pdf_input_path, 
        "output", pdf_output_file, 
        "owner_pw", owner_pw,
        "user_pw", user_pw,
        "encrypt_128bit", 
        "allow", "Printing", "CopyContents"
      ]
    )

    case status do
      0 ->  { :ok, pdf_output_file }
      _ ->  { :error, "Encrpying the PDF via pdftk failed" }
    end

  end

end
