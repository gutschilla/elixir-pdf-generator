use Mix.Config

config :pdf_generator,
  command_prefix: "xvfb-run",
  raise_on_missing_wkhtmltopdf_binary: true
