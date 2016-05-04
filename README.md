# elixir-pdf-generator

A simple wrapper for wkhtmltopdf (HTML to PDF) and PDFTK (adds in encryption) for use in Elixir projects.
It is currently using temporary files instead of pipes or other means of IPC.

# New in 0.3.2 and 0.3.3

  - 0.3.3
    -BUGFIX: typo in config/prod.exs
  - 0.3.2
    - support for command prefixes, most notabably **xvfb-run** to let a
      wkhtmltopdf which was compiled without an unpatched version of qt run on
      machines without an x server
    - (add in precompiled, patched binaries for wkhtmltopdf and libjpeg8 that are
      needed to run wkhtmltopdf without xvfb-run)

For a proper changelog, see [CHANGES](CHANGES.md)

# Usage

Download wkhtmltopdf and place it in your $PATH. Current binaries can be found here:
http://wkhtmltopdf.org/downloads.html

For best results, download goon and place it yout $PATH. Current binaries can be found here:
https://github.com/alco/goon/releases

Install pdftk (optional) via your package manager or homebrew. The project page also contains a Windows installer

Add this to your dependencies in your mix.exs:

    def application do
        [applications: [
            :logger, 
            :pdf_generator # <-- add this
        ]]
    end
    
    defp deps do
        [
            # ... whatever else
            { :pdf_generator, ">=0.3.0" }, # <-- and this
        ]
    end

Then pass some html to PdfGenerator.generate

```
$ iex -S mix

html = "<html><body><p>Hi there!</p></body></html>"
# be aware, this may take a while...
{ :ok, file_name } = PdfGenerator.generate html, page_size: "A5", open_password: "s3cr3t" 
{ :ok, pdf_content } = File.read file_name 
```

# Configuration

This module will automatically try to finde both `wkhtmltopdf` and `pdftk` in
your path. But you may override or explicitly set their paths in your
config/config.exs:

```
config :pdf_generator,
    wkhtml_path:    "/usr/bin/wkhtmltopdf",
    pdftk_path:     "/usr/bin/pdftk",
    command_prefix: "xvfb-run"
```

# Documentation

For more info, read the [docs on hex](http://hexdocs.pm/pdf_generator) or issue
`h PdfGenerator` in your iex shell.

TODO
====

- [ ] Pass some useful base path so wkhtmltopdf can resolve static files
  (styles, images etc) linked in the HTML
