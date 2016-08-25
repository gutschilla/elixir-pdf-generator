# elixir-pdf-generator

A wrapper for wkhtmltopdf (HTML to PDF) and PDFTK (adds in encryption) for use
in Elixir projects. If available, it will use xvfb-run (x virtual frame buffer)
to use wkhtmltopdf on systems that have no X installed, e.g. a server.

# New in 0.3.4 and 0.3.5

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

For a proper changelog, see [CHANGES](CHANGES.md)

# System prerequisites

Download wkhtmltopdf and place it in your $PATH. Current binaries can be found
here: http://wkhtmltopdf.org/downloads.html

_(optional)_ To use wkhtmltopdf on systems without an X window server installed,
please install `xvfb-run` from your repository (on Debian/Ubuntu: `sudo apt-get
install xvfb`).

On current (2016) Macintosh computers `/usr/X11/bin/xvfb` should be available
and is reported to do the same thing. _warning:_ This is untested. PLS report to
me if you ran this successfully on a Mac.

_(optional)_ For best results, download goon and place it in your $PATH. Current
binaries can be found here: https://github.com/alco/goon/releases

_(optional)_ Install pdftk (optional) via your package manager or homebrew. The
project page also contains a Windows installer

# Usage

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
{ :ok, filename }    = PdfGenerator.generate html, page_size: "A5", open_password: "s3cr3t" 
{ :ok, pdf_content } = File.read file_name 

# or, if you prefail methods that rais on error:
filename             = PdfGenerator.generate! html
```

Or use the bang-methods:

```
filename   = PdfGenerator.generate! "<html>..."
pdf_binary = PdfGenerator.generate_binary! "<html>..."
```

# Options and Configuration

This module will automatically try to finde both `wkhtmltopdf` and `pdftk` in
your path. But you may override or explicitly set their paths in your
`config/config.exs`. 

```
config :pdf_generator,
    wkhtml_path:    "/usr/bin/wkhtmltopdf",
    pdftk_path:     "/usr/bin/pdftk"
```

## Running headless (server-mode)

If you happen to want to run an wkhtmltopdf with an unpatched version of webkit
that requires an X Window server - but on your server (or Mac) ain't one, you
might find a `command_prefix` handy:

```
PdfGenerator.generate "<html..", command_prefix: "xvfb-run" 
```

This can also be configured globally in cour `config/config.exs`:

```
config :pdf_generator,
    command_prefix: "/usr/bin/xvfb-run"
```

## More options
 
- `page_size`:        defaults to `A4`, see wkhtmltopdf for more options 
- `open_password`:    requires `pdftk`, password to encrypt PDFs with
- `edit_password`:    requires `pdftk`, sets password for edit permissions on PDF
- `shell_params`:     pass custom parameters to wkhtmltopdf. **CAUTION: BEWARE OF SHELL INJECTIONS!** 
- `command_prefix`:   prefix wkhtmltopdf with some command (e.g. `xvfb-run`, `sudo` ..)
- `delete_temporary`: immediately remove temp files after generation

# Documentation

For more info, read the [docs on hex](http://hexdocs.pm/pdf_generator) or issue
`h PdfGenerator` in your iex shell.
