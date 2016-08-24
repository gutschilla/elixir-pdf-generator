defmodule PdfGenerator do

  @vsn "0.3.0"

  @moduledoc """
  # PdfGenerator

  Provides a simple wrapper around [wkhtmltopdf](http://wkhtmltopdf.org) and
  [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) to generate
  possibly encrypted PDFs from an HTML source.

  # Configuration (optional)

  if no or partial configuration is given, PdfGenerator will search for
  executables on path. This will rais an error when wkhtmltopdf cannot be
  found.

      config :pdf_generator,
            wkhtml_path: "/path/to/wkhtmltopdf",
            pdftk_path:  "/path/to/pdftk",


  In your config/config.exs. Add :pdf_generator to your mix.exs:
  Note that this is optional but advised to as it will perform a check on
  startup whether it can find a suitable wkhtmltopdf executable. It's
  generally better to have an app fail at startup than at later runtime.

    def application do
      [applications: [ .., :pdf_generator, ..], .. ]
    end

  If you don't want to autostart, issue

    PdfGenerator.start wkhtml_path: "/path/to/wkhtml_path"

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

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
      import Supervisor.Spec, warn: false

      children = [
        # Define workers and child supervisors to be supervised
        # worker(TestApp.Worker, [arg1, arg2, arg3])
        worker(
          PdfGenerator.PathAgent, [[
            wkhtml_path:    Application.get_env(:pdf_generator, :wkhtml_path),
            pdftk_path:     Application.get_env(:pdf_generator, :pdftk_path),
          ]]
        )
      ]

      opts = [strategy: :one_for_one, name: PdfGenerator.Supervisor]
      Supervisor.start_link(children, opts)
  end

  # return file name of generated pdf
  # requires: Porcelain, Misc.Random
  @doc """
  Generates a pdf file from given html string. Returns a string containing a
  temporary file path for that PDF.

  options:

   - page_size: output page size, defaults to "A4"
   - open_password: password required to open PDF. Will apply encryption to PDF
   - edit_password: password required to edit PDF
   - shell_params: list of command-line arguments to wkhtmltopdf
     see http://wkhtmltopdf.org/usage/wkhtmltopdf.txt for all options
   - delete_temporary: :html to remove the temporary html generated in
     the system tmp dir

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
    wkhtml_path = PdfGenerator.PathAgent.get.wkhtml_path
    html_file = Path.join System.tmp_dir, Misc.Random.string <> ".html"
    File.write html_file, html
    pdf_file  = Path.join System.tmp_dir, Misc.Random.string <> ".pdf"

    shell_params = [
      "--page-size", Keyword.get( options, :page_size ) || "A4",
      Keyword.get( options, :shell_params ) || [] # will be flattened
    ]

    executable     = wkhtml_path
    arguments      = List.flatten( [ shell_params, html_file, pdf_file ] )
    command_prefix = Keyword.get( options, :command_prefix ) || Application.get_env( :pdf_generator, :command_prefix )

    # allow for xvfb-run wkhtmltopdf arg1 arg2
    # or sudo wkhtmltopdf ...
    { executable, arguments } =
      case command_prefix do
        nil -> { executable, arguments }
        cmd -> { cmd, [executable] ++ arguments }
      end

    %Result{ out: _output, status: status, err: error } = Porcelain.exec(
      executable, arguments, [in: "", out: :string, err: :string]
    )

    if Keyword.get(options, :delete_temporary) == :html do
       File.rm html_file
    end

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
      _ -> { :error, error }
    end
  end

  def encrypt_pdf( pdf_input_path, user_pw, owner_pw ) do
    pdftk_path = PdfGenerator.PathAgent.get.pdftk_path

    owner_pw =
      case owner_pw do
        nil -> Misc.Random.string(16)
        _   -> owner_pw
      end

    user_pw =
      case user_pw do
        nil -> Misc.Random.string(16)
        _   -> user_pw
      end

    pdf_output_file  = Path.join System.tmp_dir, Misc.Random.string <> ".pdf"

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
