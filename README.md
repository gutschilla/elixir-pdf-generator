# elixir-pdf-generator

A wrapper for both wkhtmltopdf and chrome-headless plus PDFTK (adds in
encryption) for use in Elixir projects.

```Elixir
{:ok, pdf} = PdfGenerator.generate_binary("<html><body><h1>Yay!</h1></body></html>")
```

# Latest release v0.5.5 on 2019-06-18

- 0.5.5
  - improved documentation on `prefer_system_executable: true` for chrome
  - improved documentation on `no_sandbox: true` for chrome in dockerized
    environment (running as root)
  - log call options as debug info to Logger

For a proper changelog, see [CHANGES](CHANGES.md)

# System prerequisites 

It's either 

* wkhtmltopdf or 

* nodejs and possibly chrome/chromium

## chrome-headless

This will allow you to make more use of Javascript and advanced CSS as it's just
your Chrome/Chromium browser rendering your web page as HTML and printing it as
PDF. Rendering _tend_ to be a bit faster than with wkhtmltopdf. The price tag is
that PDFs printed with chrome/chromium are usually considerably bigger than
those generated with wkhtmltopdf.

1. Run `npm -g install chrome-headless-render-pdf puppeteer`. 

   This requires [nodejs](https://nodejs.org), of course. This will install a
   recent chromium and chromedriver to run Chrome in headless mode and use this
   browser and its API to print PDFs globally on your machine.
   
   If you prefer a project-local install, just use `npm install` This will
   install dependencies under `./node_modules`. Be aware that those won't be
   packaged in your distribution (I will add support for this later).

   On some machines, this doesn't install Chromium and fails. Here's how to get
   this running on Ubuntu 18:
   
   ```
   DEBIAN_FRONTEND=noninteractive PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=TRUE \
     apt-get install -y chromium-chromedriver \
     && npm -g install chrome-headless-render-pdf puppeteer
   ```
   
## wkhtmltopdf

2. Download wkhtmltopdf and place it in your $PATH. Current binaries can be
   found here: http://wkhtmltopdf.org/downloads.html
   
   For the impatient (Ubuntu18):
   
   ```
   apt-get -y install xfonts-base xfonts-75dpi \
    && wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
   ```
   
## optional dependencies

3. _optional:_ Install `xvfb` (shouldn't be required with the binary mentioned above):

   To use other wkhtmltopdf executables comiled with an unpatched Qt on systems
   without an X window server installed, please install `xvfb-run` from your
   repository (on Debian/Ubuntu: `sudo apt-get install xvfb`).
   
   I haven't heard any feedback of people using this feature since a while since
   the wkhtmltopdf projects ships ready-made binaries. I will deprecate this
   starting in `0.6.0` since, well, YAGNI.

4. _optional:_ Install `pdftk` via your package manager or homebrew. The project
   page also contains a Windows installer. On Debian/Ubuntu just type:
   `apt-get -y install pdftk`

# Usage

Add this to your dependencies in your mix.exs:

```Elixir
    def application do
        [applications: [
            :logger,
            :pdf_generator # <-- add this
        ]]
    end

    defp deps do
        [
            # ... whatever else
            { :pdf_generator, ">=0.5.5" }, # <-- and this
        ]
    end
```

Then pass some html to PdfGenerator.generate

```Elixir
$ iex -S mix

html = "<html><body><p>Hi there!</p></body></html>"
# be aware, this may take a while...
{:ok, filename}    = PdfGenerator.generate(html, page_size: "A5")
{:ok, pdf_content} = File.read(filename)

# or, if you prefer methods that raise on error:
filename = PdfGenerator.generate!(html, generator: :chrome)
```

Or, pass some URL

```Elixir
PdfGenerator.generate {:url, "http://google.com"}, page_size: "A5"
```

Or, use **chrome-headless** – if you're (most probably) using this as
dependency, chrome won't be installed to this project directory but globally. We
currently need to tell PdfGenerator this by setting the
`prefer_system_executable: true` option. This will be default by v0.6.0.

```Elixir
html_works_too = "<html><body><h1>Minimalism!"
{:ok, filename} = PdfGenerator.generate html_works_too, generator: :chrome, prefer_system_executable: true
```

If using chrome in a superuser/root environment (read: **docker**), make sure to
pass an option to chrome to disable sandboxing. And be aware of the implications.

```Elixir
html_works_too = "<html><body><h1>I need Docker, baby docker is what I need!"
{:ok, filename} = PdfGenerator.generate html_works_too, generator: :chrome, no_sandbox: true
```

Or use the bang-methods:

```Elixir
filename   = PdfGenerator.generate! "<html>..."
pdf_binary = PdfGenerator.generate_binary! "<html>..."
```

# Options and Configuration

This module will automatically try to finde both `wkhtmltopdf` and `pdftk` in
your path. But you may override or explicitly set their paths in your
`config/config.exs`.

```Elixir
config :pdf_generator,
    wkhtml_path:    "/usr/bin/wkhtmltopdf",   # <-- this program actually does the heavy lifting
    pdftk_path:     "/usr/bin/pdftk"          # <-- only needed for PDF encryption
```

or, if you prefer chrome-headless

```
config :pdf_generator,
    use_chrome: true,                           # <-- make sure you installed node/puppeteer
    prefer_system_executable: true              # <-- set this if you installed the NPM dependencies globally
    raise_on_missing_wkhtmltopdf_binary: false, # <-- so the app won't complain about a missing wkhtmltopdf
```

## More options

- `filename` - filename for the output pdf file (without .pdf extension, defaults to a random string)

- `page_size`:
  * defaults to `A4`, see `wkhtmltopdf` for more options
  * A4 will be translated to `page-height 11` and `page-width 8.5` when
    chrome-headless is used

- `open_password`:    requires `pdftk`, set password to encrypt PDFs with

- `edit_password`:    requires `pdftk`, set password for edit permissions on PDF

- `shell_params`:     pass custom parameters to `wkhtmltopdf`. **CAUTION: BEWARE OF SHELL INJECTIONS!**

- `command_prefix`:   prefix `wkhtmltopdf` with some command or a command with options
                      (e.g. `xvfb-run -a`, `sudo` ..)

- `delete_temporary`: immediately remove temp files after generation

## Contribution; how to run tests

You're more than welcome ot submit patches. Please run `mix test` to ensure at bit of stability. Tests require a full-fledged environment, with all of `wkhtmltopdf`, `xvfb` and `chrome-headless-render-pdf` available path. Also make to to have run `npm install` in the app's base directory (will install chrome-headless-render-pdf non-globally in there). With all these installed, `mix test` should run smoothly.

_Hint_: Getting `:enoent` errors ususally means that chrome or xvfb couldn't be run. Yes, this should output a nicer error.

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

## Running non-patched wkhtmltopdf headless

This section only applies to `wkhtmltopdf` users using wkhtmltopdf w/o the qt patch. If you are using the latest 0.12 binaries from https://downloads.wkhtmltopdf.org (recommended) you can safely skip this section.

If you want to run `wkhtmltopdf` with an unpatched verison of webkit that requires
an X Window server, but your server (or Mac) does not have one installed,
you may find the `command_prefix` handy:

```Elixir
PdfGenerator.generate "<html..", command_prefix: "xvfb-run"
```

This can also be configured globally in your `config/config.exs`:

```Elixir
config :pdf_generator,
    command_prefix: "/usr/bin/xvfb-run"
```

If you will be generating multiple PDFs simultaneously, or in rapid succession,
you will need to configure `xvfb-run` to search for a free X server number,
or set the server number explicitly. You can use the `command_prefix` to pass
options to the `xvfb-run` command.

```Elixir
config :pdf_generator,
    command_prefix: ["xvfb-run", "-a"]
```

# Documentation

For more info, read the [docs on hex](http://hexdocs.pm/pdf_generator) or issue
`h PdfGenerator` in your iex shell.
