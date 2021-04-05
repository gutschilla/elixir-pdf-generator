# Changelog

  - 0.6.0
    - introducing `make` as build tool (optional) for chromium binaries
      (puppeteer)
    - **BUGFIX:** documentation: option `pagesize` requires string argument
      (for example `"letter"` or `"A4"`)
    - updated some npm dependencies for chromium
  - 0.5.7
    - **BUGFIX:** fix chrome-option parameter handling
  - 0.5.6
    - **BUGFIX:** fix A4 and A5 paper sizes in inches for **chrome-headless**:
      it's not 8.5 x 11.0 (US letter) but 8.26772 x 11.695 (DIN A4), the former
      being chrome-headless defaults. This is important if you want to create
      proper A4 pages
    - Users printing **US letter** sized PDFs, please use `page_size: "letter"`
  - 0.5.5
    - improved documentation on `prefer_system_executable: true` for chrome.
      Thanks to [Martin Richer](https://github.com/richeterre) for raising this
      and a [PR](https://github.com/gutschilla/elixir-pdf-generator/pull/55)
    - improved documentation on `no_sandbox: true` for chrome in dockerized
      environment (running as root)
    - clarify that wkhtmltopdf installation snippet is for Ubuntu 18.04.
    - log call options as debug info to Logger
    - add "knows issues" section to README
  - 0.5.4
    - **BUGFIX** introduced in 0.5.0 that would crash `PdfGenerator.PathAgent`
      when chrome isn't found on path in certain situation. Thanks to
      [@radditude](https://github.com/radditude) for submitting a patch.
  - 0.5.3
    - **BUGFIX** introduced in 0.5.0 when certain shells don't accept
      `["foo=bar", …]` parameters which should correctly be `["foo", "bar"]`
      Thanks to [@egze](https://github.com/egze) for submitting a patch.
    - Refactored `PathAgent` that holds configuration state for readability and
      more fashionable and extensible error messages. Extensible towards new
      generators.
    - Updated README to be more elaborative on how to install `wkhtmltopdf` and
      `chrome-headless-render-pdf`
  - 0.5.2
    - **BUGFIX** introduced in 0.5.0 when global options to wkhtmltopdf weren't
      accepted any more due to wrong shell parameter order. Thanks to
      [manukall](https://github.com/manukall) for reporting.
  - 0.5.1
    - allow chrome to be executed as root via default config option
      `disable_chrome_sandbox` – this is required for an easy usage within a
      docker container as in
      [elixir-pdf-server](https://github.com/gutschilla/elixir-pdf-server)
  - 0.5.0
    - **Got rid of Porcelain** dependency as it interferes with many builds using
      plain `System.cmd/3`. Please note, that as of the documentation
      (https://hexdocs.pm/elixir/System.html#cmd/3) ports will be closed but in
      case wkhtmltopdf somehow hangs, nobody takes care of terminating it.
    - Refactored some sections
    - **Support URLs** instead of just plain HTML
    - **Support for chrome-headless** for (at least for me) faster and nicer renderings.
    - Since this is hopefully helpful, I rose the version to 0.5.0 even tough
      the API stays consistent
  - 0.4.0
    - Got rid of misc_random dependency. This was here to manage between
      depreciated random functions in Erlang. We go ahead using plain
      `Enum.random/1` instead, implementing our own
      `PdfGenerator.Random.string/1` function. This also removes a common
      pitfall when drafting a release with distillery.
      * Thanks to [Hugo Maia Vieira](https://github.com/hugomaiavieira) for this
        contribution!
      * Since `Enum.random/1` is only available since September 2015 (three
        years ago) I am OK with raising the minimum Elixir version to v1.1 –
        Since this may break projects still running on Elixir v1.0
        **I bumped the version to 0.4.0***.
  - 0.3.7
    - Adding in raise_on_missing_wkhtmltopdf_binary config, thanks
      to [veverkap](https://github.com/veverkap)
    - Document using xvfb-run with auto-servernum option, thanks
      to [Tony van Riet](https://github.com/tonyvanriet)
  - 0.3.6
    - bumped dependencies:
      * porcelain 2.0.3 to support newer Erlang and remove warnings
      * ex_doc 0.16 to remove warnings, remove from runtime
      * removed explicit earmark
    - add option to pick output PDF filename, thanks
      to [praveenperera](https://github.com/praveenperera)
    - improved README on Heroku, corrected typos. Thanks
      to [jbhatab](https://github.com/jbhatab)
      and [maggy96](https://github.com/maggy96)
  - 0.3.5
    - add `generate_binary` and `generate_binary!` that immediately return the
      PDF binary instead of an `{:ok, filename}` tuple.
    - add `generate!` to immediately return the filename
    - some more tests
    - minor change `delete_temporary` must be truthy. (the old supported value
      `:html` will still work) and will delete both intermediate HTML And PDF
      files in `generate_binary` and `generate_binary!`
  - 0.3.5
    - add `generate_binary` and `generate_binary!` that immediately return the
      PDF binary instead of an `{:ok, filename}` tuple.
    - add `generate!` to immediately return the filename
    - some more tests
    - minor change `delete_temporary` must be truthy. (the old supported value
      `:html` will still work) and will delete both intermediate HTML And PDF
      files in `generate_binary` and `generate_binary!`
  - 0.3.4
    - BUGFIX: fix merge confusion to **really** support `xvfb-run` or other
      command prefixes to wkhtmltopdf
    - support explicit deletion of temporary files thanks to
      [Edipo Vinicius da Silva](https://github.com/edipox)
    - Improve README
  - 0.3.3
    - BUGFIX: typo in config/prod.exs
  - 0.3.2
    - support for command prefixes, most notably **xvfb-run** to let a
      wkhtmltopdf which was compiled without an unpatched version of qt run on
      machines without an x server
    - (add in precompiled, patched binaries for wkhtmltopdf and libjpeg8 that are
      needed to run wkhtmltopdf without xvfb-run)
  - 0.3.1
    - implement this as proper application, look for executables at startup (and
      possibly fail on that)
    - save paths in a PfdGenerator.Agent
    - make paths configurable in `config/ENV.exs` as well
    - add some tests (Yay!)
    - better README- 0.3.0
  - 0.2.0
    - adding support for PDFTK to create encrypted PDFs
    - **API-CHANGE** PdfGenerator.generate now returns tuple `{:ok, file_name}`
      instead of just `file_name`
    - Adding some docs, issue `h PdfGenerator` in your iex shell for more info
