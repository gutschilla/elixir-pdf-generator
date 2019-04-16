# Changes
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
      * porcelain 2.0.3 to support newer erlangs and remove warnings
      * ex_doc 0.16 to remove warnings, remove from runtime
      * removed explixit earmark
    - add option to pick output pdf filename, thanks
      to [praveenperera](https://github.com/praveenperera)
    - improved README on heroku, corrected typos. Thanks
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
    - support for command prefixes, most notabably **xvfb-run** to let a
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

