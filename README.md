# elixir-pdf-generator

A wrapper for wkhtmltopdf (HTML to PDF) and PDFTK (adds in encryption) for use
in Elixir projects. If available, it will use xvfb-run (x virtual frame buffer)
to use wkhtmltopdf on systems that have no X installed, e.g. a server.

# New in 0.4.0 - remove misc_random, require Elixir v1.1

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

For a proper changelog, see [CHANGES](CHANGES.md)

# System prerequisites

Download wkhtmltopdf and place it in your $PATH. Current binaries can be found
here: http://wkhtmltopdf.org/downloads.html

_(optional)_ To use wkhtmltopdf on systems without an X window server installed,
please install `xvfb-run` from your repository (on Debian/Ubuntu: `sudo apt-get
install xvfb`).

On current (2018) Macintosh computers `/usr/X11/bin/xvfb` should be available
and is reported to do the same thing. _warning:_ This is untested. PLS report to
me if you ran this successfully on a Mac.

_(optional)_ For best results, download goon and place it in your $PATH. Current
binaries can be found here: https://github.com/alco/goon/releases

_(optional)_ Install pdftk via your package manager or homebrew. The
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
            { :pdf_generator, ">=0.4.0" }, # <-- and this
        ]
    end

Then pass some html to PdfGenerator.generate

```
$ iex -S mix

html = "<html><body><p>Hi there!</p></body></html>"
# be aware, this may take a while...
{ :ok, filename }    = PdfGenerator.generate html, page_size: "A5"
{ :ok, pdf_content } = File.read filename 

# or, if you prefer methods that raise on error:
filename            = PdfGenerator.generate! html
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
    wkhtml_path:    "/usr/bin/wkhtmltopdf",   # <-- this program actually does the heavy lifting
    pdftk_path:     "/usr/bin/pdftk"          # <-- only needed for PDF encryption
```

## Running headless (server-mode)

If you want to run `wkhtmltopdf` with an unpatched verison of webkit that requires
an X Window server, but your server (or Mac) does not have one installed,
you may find the `command_prefix` handy:

```
PdfGenerator.generate "<html..", command_prefix: "xvfb-run" 
```

This can also be configured globally in your `config/config.exs`:

```
config :pdf_generator,
    command_prefix: "/usr/bin/xvfb-run"
```

If you will be generating multiple PDFs simultaneously, or in rapid succession,
you will need to configure `xvfb-run` to search for a free X server number,
or set the server number explicitly. You can use the `command_prefix` to pass
options to the `xvfb-run` command.

```
config :pdf_generator,
    command_prefix: ["xvfb-run", "-a"]
```

## More options

- `page_size`:        defaults to `A4`, see `wkhtmltopdf` for more options 
- `open_password`:    requires `pdftk`, set password to encrypt PDFs with
- `edit_password`:    requires `pdftk`, set password for edit permissions on PDF
- `shell_params`:     pass custom parameters to `wkhtmltopdf`. **CAUTION: BEWARE OF SHELL INJECTIONS!** 
- `command_prefix`:   prefix `wkhtmltopdf` with some command or a command with options
                      (e.g. `xvfb-run -a`, `sudo` ..)
- `delete_temporary`: immediately remove temp files after generation
- `filename` - filename for the output pdf file (without .pdf extension, defaults to a random string)

## Heroku Setup

If you want to use this project on heroku, you can use buildpacks instead of binaries
to load `pdftk` and `wkhtmltopdf`:
```
https://github.com/fxtentacle/heroku-pdftk-buildpack
https://github.com/dscout/wkhtmltopdf-buildpack
https://github.com/HashNuke/heroku-buildpack-elixir
https://github.com/gjaldon/phoenix-static-buildpack
```

__note:__ The list also includes Elixir and Phoenix buildpacks to show you that they
must be placed after `pdftk` and `wkhtmltopdf`. It won't work if you load the 
Elixir and Phoenix buildpacks first.

# Documentation

For more info, read the [docs on hex](http://hexdocs.pm/pdf_generator) or issue
`h PdfGenerator` in your iex shell.
