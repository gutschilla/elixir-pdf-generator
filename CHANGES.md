# Changes

  - 0.3.1
    - implement this as proper application, look for executables at startup (and possibly fail on that)
    - save paths in a PfdGenerator.Agent
    - make paths configurable in `config/ENV.exs` as well
    - add some tests (Yay!)
    - better README- 0.3.0

  - 0.2.0 
    - adding support for PDFTK to create encrypted PDFs
    - **API-CHANGE** PdfGenerator.generate now returns tuple `{ :ok, file_name }` instead of just `file_name`
    - Adding some docs, issue `h PdfGenerator` in your iex shell for more info

