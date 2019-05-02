use Mix.Config

config :pdf_generator,
  #   wkhtml_path: "/usr/bin/wkhtmltopdf",
  #   pdftk_path:  "/usr/bin/pdftk",
  #   command_prefix:   "/usr/bin/xvfb-run",

  # allow chrome to run as root
  disable_chrome_sandbox: true

import_config "#{Mix.env}.exs"

