defmodule PdfGenerator do
  require Logger

  @vsn "0.6.0"

  @moduledoc """
  Provides a simple wrapper around [wkhtmltopdf](http://wkhtmltopdf.org) and
  [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) to generate
  possibly encrypted PDFs from an HTML source.

  ## Configuration (optional)

  if no or partial configuration is given, PdfGenerator will search for
  executables on path. This will raise an error when wkhtmltopdf cannot be
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

  ## System requirements

    * wkhtmltopdf or chrome-headless

    * pdftk (optional, for encrypted PDFs)

  Precompiled **wkhtmltopdf** binaries can be obtained here:
  http://wkhtmltopdf.org/downloads.html

  **pdftk** should be available as package on your system via

    * `apt-get install pdftk` on Debian/Ubuntu

    * `brew pdftk` on OSX (you'll need homebrew, of course)

    * Install the Exe-Installer on Windows found the project's homepage (link
    above)

  """

  use Application

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

  def defaults(), do: [generator: :wkhtmltopdf, page_size: "A4"]

  # return file name of generated pdf

  @doc """
  Generates a PDF file from given html string. Returns a string containing a
  temporary file path for that PDF.

  ## Options

  * `:generator` – either `chrome` or `wkhtmltopdf` (default)

  * `:prefer_system_executable` - set to `true` if you installed
    chrome-headless-render-pdf globally

  * `:no_sandbox` – disable sandbox for chrome, required to run as root (read: _docker_)

  * `:page_size` - output page size, defaults to "A4", other options are
    "letter" (US letter) and "A5"

  * `:open_password` - password required to open PDF. Will apply encryption to PDF

  * `:edit_password` - password required to edit PDF

  * `:shell_params` - list of command-line arguments to wkhtmltopdf or chrome
    see http://wkhtmltopdf.org/usage/wkhtmltopdf.txt for all options

  * `:delete_temporary` - true to remove the temporary html generated in
    the system tmp dir

  * `:filename` - filename you want for the output PDF (provide without .pdf extension),
    defaults to a random string

  ## Examples

      pdf_path_1 = PdfGenerator.generate "<html><body><h1>Boom</h1></body></html>"
      pdf_path_2 = PdfGenerator.generate(
        "<html><body><h1>Boom</h1></body></html>",
        page_size:     "letter",
        open_password: "secret",
        edit_password: "g3h31m",
        shell_params: [ "--outline", "--outline-depth3", "3" ],
        delete_temporary: true,
        filename: "my_awesome_pdf"
      )

  """

  @type url           :: binary()
  @type html          :: binary()
  @type pdf_file_path :: binary()
  @type content       :: html | {:url, url} | {:html, html}
  @type reason        :: atom() | {atom(), any}
  @type opts          :: keyword()
  @type path          :: binary()
  @type html_path     :: path
  @type pdf_path      :: path
  @type generator     :: :wkhtmltopdf | :chrome

  @spec generate(content, opts) :: {:ok, pdf_file_path} | {:error, reason}
  def generate(content, opts \\ []) do

    options = Keyword.merge(defaults(), opts)

    generator     = options[:generator]

    open_password = options[:open_password]
    edit_password = options[:edit_password]
    delete_temp   = options[:delete_temporary]

    with {html_file, pdf_file}       <- make_file_paths(options),
         :ok                         <- maybe_write_html(content, html_file),
         {executable, arguments}     <- make_command(generator, options, content, {html_file, pdf_file}),
         {:cmd, {stderr, exit_code}} <- {:cmd, System.cmd(executable, arguments, stderr_to_stdout: true)},       # unfortunately wkhtmltopdf returns 0 on errors as well :-/
         {:result_ok, true, _err}    <- {:result_ok, result_ok(generator, stderr, exit_code), stderr},           # so we inspect stderr instead
         {:rm, :ok}                  <- {:rm, maybe_delete_temp(delete_temp, html_file)},
         {:ok, encrypted_pdf}        <- maybe_encrypt_pdf(pdf_file, open_password, edit_password) do
      {:ok, encrypted_pdf}
    else
      {:error, reason}     -> {:error, reason}
      {:result_ok, _, err} -> {:error, {:generator_failed, err}}
      reason               -> {:error, reason}
    end
  end

  @spec maybe_write_html(content, path()) :: :ok | {:error, reason}
  def maybe_write_html({:url, _url}, _html_file_path),                      do: :ok
  def maybe_write_html({:html, html}, html_file_path),                      do: File.write(html_file_path, html)
  def maybe_write_html(html,          html_file_path) when is_binary(html), do: maybe_write_html({:html, html}, html_file_path)

  @spec make_file_paths(keyword()) :: {html_path, pdf_path}
  def make_file_paths(options) do
    filebase = options[:filename] |> generate_filebase()
    {filebase <> ".html", filebase <> ".pdf"}
  end

  def make_dimensions(options) when is_list(options) do
    options |> Enum.into(%{}) |> dimensions_for()
  end

  @doc ~s"""
  Returns `{width, height}` tuple for page sizes either as given or for A4 and
  A5.

  Defaults to A4 sizes. In inches. Because chrome wants imperial.
  """
  def dimensions_for(%{page_width: width, page_height: height}), do: {width, height}
  def dimensions_for(%{page_size: "A4"}),                        do: {"8.26772", "11.695"}
  def dimensions_for(%{page_size: "A5"}),                        do: {"5.8475",  "8.26772"}
  def dimensions_for(%{page_size: "letter"}),                    do: {"8.5",     "11"}
  def dimensions_for(_map),                                      do: dimensions_for(%{page_size: "A4"})

  @spec make_command(generator, opts, content, {html_path, pdf_path}) :: {path, list()}
  def make_command(:chrome, options, content, {html_path, pdf_path}) do
    chrome_executable  = PdfGenerator.PathAgent.get.chrome_path
    node_executable    = PdfGenerator.PathAgent.get.node_path
    disable_sandbox    = Application.get_env(:pdf_generator, :disable_chrome_sandbox) || options[:no_sandbox]

    dir =
      if options[:prefer_local_executable] do
        Path.expand("assets")
      else
        # needs `make priv/node_modules` to be run when building
        :code.priv_dir(:pdf_generator) |> to_string()
      end

    js_file  = "#{dir}/node_modules/chrome-headless-render-pdf/dist/cli/chrome-headless-render-pdf.js"

    {executable, executable_args} =
      if options[:prefer_system_executable] && is_binary(chrome_executable) do
        {chrome_executable, []}
      else
        {node_executable, [js_file]}
      end

    {width, height} = make_dimensions(options)
    more_params = options[:shell_params] || []
    source =
      case content do
        {:url,  url} -> url
        _html        -> "file://" <> html_path
      end
    arguments = List.flatten([
      executable_args,
      [
        "--url", source,
        "--pdf", pdf_path,
        "--paper-width",   width,
        "--paper-height", height,
      ],
      more_params,
      if(disable_sandbox, do: ["--chrome-option=--no-sandbox"], else: [])
    ])
    {executable, arguments} |> inspect() |> Logger.debug()
    {executable, arguments}
  end

  def make_command(:wkhtmltopdf, options, content, {html_path, pdf_path}) do
    executable  = PdfGenerator.PathAgent.get.wkhtml_path
    source =
      case content do
        {:url, url} -> url
        _html       -> html_path
      end
    shell_params = options[:shell_params] || []
    arguments = List.flatten([
      shell_params,
      "--page-size", options[:page_size] || "A4",
      source, pdf_path
    ])
    # for wkhtmltopdf we support prefixes like ["xvfb-run", "-a"] to precede the actual command
    {executable, arguments} =
      case get_command_prefix(options) do
        nil                    -> {executable, arguments}
        [prefix | prefix_args] -> {prefix, prefix_args ++ [executable] ++ arguments}
        prefix                 -> {prefix, [executable | arguments]}
      end
    {executable, arguments} |> inspect() |> Logger.debug()
    {executable, arguments}
  end

  defp maybe_delete_temp(true,    file), do: File.rm(file)
  defp maybe_delete_temp(_falsy, _file), do: :ok

  def maybe_encrypt_pdf(pdf_file, open_password, edit_password)
  when is_binary(open_password) or is_binary(edit_password) do
    encrypt_pdf(pdf_file, open_password, edit_password)
  end

  def maybe_encrypt_pdf(pdf_file, _open_password, _edit_password) do
    {:ok, pdf_file}
  end

  defp result_ok(:chrome,     _string,          0), do: true
  defp result_ok(:chrome,     _string, _exit_code), do: false
  defp result_ok(:wkhtmltopdf, string, _exit_code), do: String.match?(string, ~r/Done/ms)

  defp get_command_prefix(options) do
    options[:command_prefix] || Application.get_env(:pdf_generator, :command_prefix)
  end

  defp generate_filebase(nil), do: generate_filebase(PdfGenerator.Random.string())
  defp generate_filebase(filename), do: Path.join(System.tmp_dir, filename)

  def encrypt_pdf(pdf_input_path, user_pw, owner_pw ) do
    pdftk_path      = PdfGenerator.PathAgent.get.pdftk_path
    pdf_output_file = Path.join System.tmp_dir, PdfGenerator.Random.string() <> ".pdf"

    pdftk_args = [
      pdf_input_path,
      "output", pdf_output_file,
      "owner_pw", random_if_undef(owner_pw),
      "user_pw",  random_if_undef(user_pw),
      "encrypt_128bit", "allow", "Printing", "CopyContents"
    ]

    {stderr, exit_code} = System.cmd(pdftk_path, pdftk_args, stderr_to_stdout: true)

    case exit_code do
      0 ->  {:ok, pdf_output_file}
      _ ->  {:error, {:pdftk, stderr}}
    end
  end

  defp random_if_undef(nil), do: PdfGenerator.Random.string(16)
  defp random_if_undef(any), do: any

  @doc """
  Takes same options as `generate` but will return an:

      `{:ok, binary_pdf_content}` tuple.

  In case option `:delete_temporary` is `true`, will delete the temporary
  PDF file as well.
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
