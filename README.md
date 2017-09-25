# elixir-pdf-generator

A wrapper for wkhtmltopdf (HTML to PDF) and PDFTK (adds in encryption) for use
in Elixir projects. If available, it will use xvfb-run (x virtual frame buffer)
to use wkhtmltopdf on systems that have no X installed, e.g. a server.

# New in 0.3.6 - Custom filenames and maintenance

  - 0.3.6
    - bumped dependencies:
      * porcelain 2.0.3 to support newer erlangs and remove warnings
      * ex_doc 0.16 to remove warnings, remove from runtime
      * removed explixit earmark
    - add option to pick output pdf filename, thanks
      to [praveenperera](https://github.com/praveenperera)
    - improved README on heroku, corrected typpos. Thanks
      to [jbhatab](https://github.com/jbhatab)
      and [maggy96](https://github.com/maggy96)

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
            { :pdf_generator, ">=0.3.5" }, # <-- and this
        ]
    end

Then pass some html to PdfGenerator.generate

```
$ iex -S mix

html = "<html><body><p>Hi there!</p></body></html>"
# be aware, this may take a while...
{ :ok, filename }    = PdfGenerator.generate html, page_size: "A5"
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
    wkhtml_path:    "/usr/bin/wkhtmltopdf",   # <-- this program actually does the heavy lifting
    pdftk_path:     "/usr/bin/pdftk"          # <-- only needed for PDF encryption
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
- `filename` - filename you want for the output PDF (provide without .pdf extension),
     defaults to a random string

## Heroku Setup

If you are using this with heroku, you can use buildpacks instead of binaries to load in pdftk and wkhtmltopdf. Here's an example buildpack file. 

```
https://github.com/fxtentacle/heroku-pdftk-buildpack.git
https://github.com/dscout/wkhtmltopdf-buildpack.git
https://github.com/HashNuke/heroku-buildpack-elixir
https://github.com/gjaldon/phoenix-static-buildpack
```

note: this has elixir and phoenix buildpacks in here as well to show that they have to be placed after the wkhtmltopdf and pdftk buildpacks. It won't work if they come after elixir/phoenix buildpacks.

# Documentation

For more info, read the [docs on hex](http://hexdocs.pm/pdf_generator) or issue
`h PdfGenerator` in your iex shell.

# Common issues

## Running from within distillery or exrm releases

**ERROR** 

`(UndefinedFunctionError) function Misc.Random.string/0 is undefined (module Misc.Random is not available)`

**FIX**

For now, unfortunately, it's required to add `misc_random` to either your
`included_applications` section in your `mix.exs` (exrm) or for (distillery) add
it to your release/applications list in `rel/config.exs`.

```
...
release :your_app do
  set version: current_version(:your_app)
  set applications: [:misc_random]
end
```
