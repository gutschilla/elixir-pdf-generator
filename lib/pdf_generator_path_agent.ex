defmodule PdfGenerator.PathAgent do
  require Logger
  defstruct [
    wkhtml_path: nil,
    pdftk_path:  nil,
    chrome_path: nil,
    node_path:   nil,
  ]

  @moduledoc """
  Will check for system executables at startup time and store paths. If
  configured as such, will raise an error when no usable executable was found.

  The idea is to perform this kind of auto-configuration at startup and then
  store the values in this agent. The same could probably be achieved with
  `Application.put_env/3`. Comments on this welcome. Until then, this just works.
  """

  @name __MODULE__

  def start_link( path_options ) do
    Agent.start_link( __MODULE__, :init_opts, [ path_options ], name: @name  )
  end

  def init_opts( paths_from_options ) do
    # options override system default paths
    options =
      [
        wkhtml_path: System.find_executable("wkhtmltopdf"),
        pdftk_path:  System.find_executable("pdftk"),
        chrome_path: System.find_executable("chrome-headless-render-pdf"),
        node_path:   System.find_executable("nodejs") || System.find_executable("node"),
      ]
      ++ paths_from_options
      |> Enum.dedup()
      |> Enum.filter( fn { _, v } -> v != nil end )
      |> raise_or_continue()

    Map.merge %PdfGenerator.PathAgent{}, Enum.into( options, %{} )
  end

  @doc "Stops agent, returns :ok"
  def stop do
    Agent.stop @name
  end

  @doc "Returns path state as struct"
  def get do
    Agent.get( @name, fn( data ) -> data end )
  end

  @doc """
  Checks options for generator binaries (chrome-headless-render-pdf and
  wkhtmltopdf) exists on path. Raises an error if corresponding options are set
  to true:

    * `:raise_on_missing_wkhtmltopdf_binary`
    * `:raise_on_missing_chrome_binary`
    * `:raise_on_missing_binaries` -> raises on either binary missing

  """
  def raise_or_continue(options) do
    wkhtml_exists = File.exists?(options[:wkhtml_path] || "")
    chrome_exists = File.exists?(options[:chrome_path] || "")

    raise_on_wkhtml_missing = options[:raise_on_missing_wkhtmltopdf_binary]
    raise_on_chrome_missing = options[:raise_on_missing_chrome_binary]
    raise_on_any_missing =    options[:raise_on_missing_binaries]

    maybe_raise(:wkhtml, raise_on_wkhtml_missing, wkhtml_exists)
    maybe_raise(:chrome, raise_on_chrome_missing, chrome_exists)
    maybe_raise(:any,    raise_on_any_missing, wkhtml_exists or chrome_exists)

    options
  end

  defp maybe_raise(generator,  _config_says_raise = true,  _executable_exists = false), do: generator |> missing_message() |> raise()
  defp maybe_raise(generator,  _config_says_raise = false, _executable_exists = false), do: generator |> missing_message() |> Logger.warn()
  defp maybe_raise(_generator, _config_says_raise = _,     _executable_exists = _    ), do: :noop

  defp missing_message(:wkhtml), do: "wkhtmltopdf executable was not found on your system"
  defp missing_message(:chrome), do: "chrome-headless-render-pdf executable was not found on your system"
  defp missing_message(:any),    do: "neither wkhtmltopdf or chrome-headless-render-pdf executables were found on your system"

end
