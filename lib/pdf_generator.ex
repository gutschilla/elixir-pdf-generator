defmodule PdfGenerator do

  @vsn "0.3.6"

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
            wkhtml_path:                         Application.get_env(:pdf_generator, :wkhtml_path),
            pdftk_path:                          Application.get_env(:pdf_generator, :pdftk_path),
            raise_on_missing_wkhtmltopdf_binary: Application.get_env(:pdf_generator, :raise_on_missing_wkhtmltopdf_binary, true),
          ]]
        )
      ]

      opts = [strategy: :one_for_one, name: PdfGenerator.Supervisor]
      Supervisor.start_link(children, opts)
  end

  # return file name of generated pdf

  @doc """
  Generates a pdf file from given html string. Returns a string containing a
  temporary file path for that PDF.

  ## Options

   * `:page_size` - output page size, defaults to "A4"
   * `:open_password` - password required to open PDF. Will apply encryption to PDF
   * `:edit_password` - password required to edit PDF
   * `:shell_params` - list of command-line arguments to wkhtmltopdf
     see http://wkhtmltopdf.org/usage/wkhtmltopdf.txt for all options
   * `:delete_temporary` - true to remove the temporary html generated in
     the system tmp dir
   * `:filename` - filename you want for the output PDF (provide without .pdf extension),
     defaults to a random string

  # Examples

  pdf_path_1 = PdfGenerator.generate "<html><body><h1>Boom</h1></body></html>"
  pdf_path_2 = PdfGenerator.generate(
    "<html><body><h1>Boom</h1></body></html>",
    page_size:     "A5",
    open_password: "secret",
    edit_password: "g3h31m",
    shell_params: [ "--outline", "--outline-depth3", "3" ],
    delete_temporary: true,
    filename: "my_awesome_pdf"
  )
  """
  def generate( html ) do
    generate html, page_size: "A4"
  end

  def generate( html, options ) do
    wkhtml_path     = PdfGenerator.PathAgent.get.wkhtml_path
    filebase        = generate_filebase(options[:filename])
    html_file       = filebase <> ".html"
    pdf_file        = filebase <> ".pdf"
    File.write html_file, html

    shell_params = [
      "--page-size", Keyword.get( options, :page_size ) || "A4",
      Keyword.get( options, :shell_params ) || [] # will be flattened
    ]

    executable     = wkhtml_path
    arguments      = List.flatten( [ shell_params, html_file, pdf_file ] )
    command_prefix = get_command_prefix( options )

    # allow for xvfb-run wkhtmltopdf arg1 arg2
    # or sudo wkhtmltopdf ...
    { executable, arguments } = make_command_tuple(command_prefix, executable, arguments)

    %Result{ out: _output, status: status, err: error } = Porcelain.exec(
      executable, arguments, [in: "", out: :string, err: :string]
    )

    if Keyword.get(options, :delete_temporary), do: html_file |> File.rm

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

  def get_command_prefix(options) do
    Keyword.get( options, :command_prefix ) || Application.get_env( :pdf_generator, :command_prefix )
  end

  def make_command_tuple(_command_prefix = nil, wkhtml_executable, arguments) do
    { wkhtml_executable, arguments }
  end
  def make_command_tuple([command_prefix | args], wkhtml_executable, arguments) do
    { command_prefix, args ++ [wkhtml_executable] ++ arguments }
  end
  def make_command_tuple(command_prefix, wkhtml_executable, arguments) do
    { command_prefix, [wkhtml_executable] ++ arguments }
  end

  defp generate_filebase(nil), do: generate_filebase(PdfGenerator.Random.string())
  defp generate_filebase(filename), do: Path.join(System.tmp_dir, filename)

  def encrypt_pdf( pdf_input_path, user_pw, owner_pw ) do
    pdftk_path = PdfGenerator.PathAgent.get.pdftk_path
    pdf_output_file  = Path.join System.tmp_dir, PdfGenerator.Random.string() <> ".pdf"

    %Result{ out: _output, status: status } = Porcelain.exec(
      pdftk_path, [
        pdf_input_path,
        "output", pdf_output_file,
        "owner_pw", owner_pw |> random_if_undef,
        "user_pw",  user_pw  |> random_if_undef,
        "encrypt_128bit",
        "allow", "Printing", "CopyContents"
      ]
    )

    case status do
      0 ->  { :ok, pdf_output_file }
      _ ->  { :error, "Encrpying the PDF via pdftk failed" }
    end
  end

  defp random_if_undef(nil), do: PdfGenerator.Random.string(16)
  defp random_if_undef(any), do: any

  @doc """
  Takes same options as `generate` but will return an
  `{:ok, binary_pdf_content}` tuple.

  In case option _delete_temporary_ is true, will as well delete the temporary
  pdf file.
  """
  def generate_binary(html, options \\ []) do
    result = generate html, options
    case result do
      {:ok, filename}  -> {:ok, filename |> read_and_maybe_delete(options) }
      {:error, reason} -> {:error, reason}
    end
  end

  defp read_and_maybe_delete(filename, options) do
    content = filename |> File.read!
    if Keyword.get(options, :delete_temporary), do: filename |> File.rm
    content
  end

  @doc """
  Same as generate_binary but returns PDF content directly or raises on
  error.
  """
  def generate_binary!(html, options \\ []) do
    result = generate_binary html, options
    case result do
      {:ok, content}   -> content
      {:error, reason} -> raise "in-place generation failed: " <> reason
    end
  end

  @doc """
  Same as generate but returns PDF file name only (raises on error).
  """
  def generate!(html, options \\ []) do
    result = generate html, options
    case result do
      {:ok, filename}  -> filename
      {:error, reason} -> raise "HTML generation failed: " <> reason
    end
  end
end
