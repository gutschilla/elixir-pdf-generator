use Mix.Config

config :pdf_generator,
  #   wkhtml_path: "/usr/bin/wkhtmltopdf",
  #   pdftk_path:  "/usr/bin/pdftk",
  #   command_prefix:   "/usr/bin/xvfb-run",

  # allow chrome to run as root
  disable_chrome_sandbox: true

if Mix.env() == :test do
  config :pdf_generator,
    command_prefix: "xvfb-run",
    raise_on_missing_wkhtmltopdf_binary: true
end
