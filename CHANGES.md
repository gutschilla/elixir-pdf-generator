# Changes

  - 0.3.5
    - add `generate_binray` and `generate_binary!` that immediately return the
      PDF binary instead of an `{:ok, filename}` tuple.
    - add `generate!` to immediately return the filename
    - some more tests
    - minor change `delete_temporary` must be truthy. (the old supported value
      `:html` will stil work) and will delete both intermediate HTML And PDF
      files in ``generate_binary` and `generate_binary!`
  - 0.3.4
    - BUGFIX: fix merge confusion to **realy** support `xvfb-run` or other
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

