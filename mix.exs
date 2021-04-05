defmodule PdfGenerator.Mixfile do
  use Mix.Project

  @source_url "https://github.com/gutschilla/elixir-pdf-generator"
  @version "0.6.2"

  def project do
    [
      app: :pdf_generator,
      name: "PDF Generator",
      version: @version,
      elixir: ">= 1.1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      applications: [:logger],
      mod: {PdfGenerator, []}
    ]
  end

  defp package do
    [
      description:
        "A wrapper for wkhtmltopdf and chrome-headless (puppeteer) with optional " <>
          "support for encryption via pdftk.",
      files: ["lib", "mix.exs", "README.md", "LICENSE", "test", "priv"],
      maintainers: ["Martin Gutsch"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/elixir-pdf-generator/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        "CONTRIBUTING.md",
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
