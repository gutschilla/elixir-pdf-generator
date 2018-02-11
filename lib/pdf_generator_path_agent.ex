defmodule PdfGenerator.PathAgent do
  require Logger
  defstruct wkhtml_path: nil, pdftk_path: nil

  @moduledoc """
  Will check system requirements on startup and keep
  a path map as state in an Agent process.
  """

  @name __MODULE__

  def start_link( path_options ) do
    Agent.start_link( __MODULE__, :init_opts, [ path_options ], name: @name  )
  end

  def init_opts( paths_from_options ) do
    # options override system default paths
    options =
      [
        wkhtml_path:    System.find_executable( "wkhtmltopdf" ),
        pdftk_path:     System.find_executable( "pdftk" )
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

  def raise_or_continue(options) do
    exe_exists       = File.exists?(Keyword.get(options, :wkhtml_path, ""))
    raise_on_missing = Keyword.get(options, :raise_on_missing_wkhtmltopdf_binary, true)

    case {exe_exists, raise_on_missing} do
      {true, _} -> options
      {false, true} -> raise "wkhtmltopdf executable was not found on your system"
      {false, false} -> 
        Logger.warn "wkhtmltopdf executable was not found on your system"
        options
    end
  end
end
