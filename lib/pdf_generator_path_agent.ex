defmodule PdfGenerator.PathAgent do

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
      |> Enum.filter( fn { _, v } -> v != nil end )

    # at least, wkhtmltopdf executable sould be there
    if Keyword.fetch!( options, :wkhtml_path ) == nil do
      raise "path to wkhtmltopdf is neither found on path nor given as wkhtml_path option. Can't continue."
    end

    # IO.inspect options
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

end
