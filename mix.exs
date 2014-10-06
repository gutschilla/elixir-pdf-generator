defmodule PdfGenerator.Mixfile do
  use Mix.Project

  def project do
    [app: :pdf_generator,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [ applications:
        [
            :logger,
            :porcelain
        ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
        # communication with external programs
        {:porcelain, "~> 2.0"},
        {:random, github: "gutschilla/elixir-helper-random", tags: "0.2.1" },
    ]
  end
end
