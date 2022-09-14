# PDF Generator

[![CircleCI](https://circleci.com/gh/gutschilla/elixir-pdf-generator.svg?style=svg)](https://circleci.com/gh/gutschilla/elixir-pdf-generator)
[![Module Version](https://img.shields.io/hexpm/v/pdf_generator.svg)](https://hex.pm/packages/pdf_generator)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/pdf_generator/)
[![Total Download](https://img.shields.io/hexpm/dt/pdf_generator.svg)](https://hex.pm/packages/pdf_generator)
[![License](https://img.shields.io/hexpm/l/pdf_generator.svg)](https://github.com/gutschilla/elixir-pdf-generator/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/gutschilla/elixir-pdf-generator.svg)](https://github.com/gutschilla/elixir-pdf-generator/commits/master)

A wrapper for both wkhtmltopdf and chrome-headless plus PDFTK (adds in
encryption) for use in Elixir projects.

See [Changelog](./CHANGELOG.md) for recent changes.

## Usage

_Hint:_ In IEx, `h PdfGenerator.generate` is your friend.

For Elixir version earlier than 1.4:

```elixir
def application do
    [
      applications: [
        :logger,
        :pdf_generator
      ]
    ]
end
```

Add this to your dependencies in your mix.exs:

```elixir
defp deps do
[
  # ... whatever else
  {:pdf_generator, ">=0.6.0" }, # <-- and this
]
end
```

If you want to use a locally-installed chromium in **RELEASES** (think `mix
release`), alter your mixfile to let `make` take care of compilation and
dependency-fetching:

```elixir
defp deps do
  [
    {:pdf_generator, ">=0.6.2", compile: "make chrome"}
  ]
end
```
To get the latest version or if you run into issues:

```elixir
defp deps do
  [
    {:pdf_generator, "~> 0.6.2", github: "gutschilla/elixir-pdf-generator", compile: "make chrome"}
  ]
end
```

This will embed a **300 MB** (yes, that large) Chromium binary into your priv folder
which will survive packaging as Erlang release. This _can_ be handy as this will
run on slim Alpine docker images with just NodeJS installed.

The recommended way still is to install Chromium/Puppeteer globally and set the
`prefer_system_executable: true` option when generating PDFs.

In development: While this usually works, it unfortunately leads to
pdf_generator to be compiled all the time again and again due to my bad Makefile
skills. Help is very much appreciated.

Eventually, if you are using Phoenix and you would like to have your npm
packages installed locally, within the `/assets/node_modules` directory, simply
run `npm install chrome-headless-render-pdf puppeteer` within
`assets/node_modules` and pass `prefer_local_executable: true` option when
generating the PDF like this:

```elixir
PdfGenerator.generate(url, generator: :chrome, prefer_local_executable: true)
```

## Try it out

Pass some HTML to PdfGenerator.generate:

```bash
$ iex -S mix

html = "<html><body><p>Hi there!</p></body></html>"
# be aware, this may take a while...
{:ok, filename}    = PdfGenerator.generate(html, page_size: "A5")
{:ok, pdf_content} = File.read(filename)

# or, if you prefer methods that raise on error:
filename = PdfGenerator.generate!(html, generator: :chrome)
```

Or, pass some URL

```elixir
PdfGenerator.generate {:url, "http://google.com"}, page_size: "A5"
```

Or use the bang-methods:

```elixir
filename   = PdfGenerator.generate! "<html>..."
pdf_binary = PdfGenerator.generate_binary! "<html>..."
```

### Chrome

Or, use **chrome-headless**.

Unless your mixfile says `{:pdf_generator, ">=6.0.0", compile: "make chrome"}`
Chrome won't be installed into your application. Please set the
`prefer_system_executable: true` option in this case.

```elixir
html_works_too = "<html><body><h1>Minimalism!"
{:ok, filename} = PdfGenerator.generate html_works_too, generator: :chrome, prefer_system_executable: true
```

### Docker

If using chrome in a superuser/root environment (read: **docker**), make sure to
pass an option to chrome to disable sandboxing. And be aware of the implications.

```elixir
html_works_too = "<html><body><h1>I need Docker, baby docker is what I need!"
{:ok, filename} = PdfGenerator.generate html_works_too, generator: :chrome, no_sandbox: true, page_size: "letter"
```

## System prerequisites

It's either

* wkhtmltopdf or

* NodeJS (for Chrome-headless/Puppeteer)

### Chrome-headless

This will allow you to make more use of Javascript and advanced CSS as it's just
your Chrome/Chromium browser rendering your web page as HTML and printing it as
PDF. Rendering _tend_ to be a bit faster than with wkhtmltopdf. The price tag is
that PDFs printed with chrome/chromium are usually considerably bigger than
those generated with wkhtmltopdf.

### Global Install (great for Docker images)

Run `npm -g install chrome-headless-render-pdf puppeteer`.

This requires [nodejs](https://nodejs.org), of course. This will install a
recent Chromium and chromedriver to run Chrome in headless mode and use this
browser and its API to print PDFs globally on your machine.

If you prefer a project-local install, use the `compile: "make chrome"` option
in your mixfile's dependency-line.

On some machines, this doesn't install Chromium and fails. Here's how to get
this running on Ubuntu 18:

```bash
DEBIAN_FRONTEND=noninteractive PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=TRUE \
  apt-get install -y chromium-chromedriver \
  && npm -g install chrome-headless-render-pdf puppeteer
```

### Local Install

Run `make priv/node_modules`. This requires both `nodejs` (installation see
above) and `make`.

Or, run `cd priv && npm install`

### wkhtmltopdf

- **Alpine** (tested on 3.11): `apk add wkhtmltopdf` - gone are the days of
  manually fumbling around with wkhtmltopdf and its muss preference over glibc.

- **Ubuntu 19.10+**: `apt-get install wkhtmltopdf` and you'll have 0.12.5 on $PATH

- **Ubuntu 18.04**: Download wkhtmltopdf and place it in your $PATH. Current
  binaries can be found here: http://wkhtmltopdf.org/downloads.html

  For the impatient (Ubuntu 18.04 Bionic Beaver):

  ```bash
  apt-get -y install xfonts-base xfonts-75dpi \
    && wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
  ```

  For other distributions, refer to http://wkhtmltopdf.org/downloads.html – For
  example, replace `bionic` with `xenial` if you're on Ubuntu 16.04.

## Optional Dependencies

3. _optional:_ Install `xvfb` (shouldn't be required with the binary mentioned above):

   To use other wkhtmltopdf executables compiled with an unpatched Qt on systems
   without an X window server installed, please install `xvfb-run` from your
   repository (on Debian/Ubuntu: `sudo apt-get install xvfb`).

   I am glad to have received feedback that people are actually using this
   feature.

4. _optional:_ Install `pdftk` via your package manager or homebrew. The project
   page also contains a Windows installer. On Debian/Ubuntu just type:
   `apt-get -y install pdftk`

## Options and Configuration

This module will automatically try to find both `wkhtmltopdf` and `pdftk` in
your path. But you may override or explicitly set their paths in your
`config/config.exs`.

```elixir
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

### More options

- `filename` - filename for the output PDF file (without .pdf extension,
  defaults to a random string)

- `page_size` - defaults to `"A4"`, see `wkhtmltopdf` for more options.
  `"letter"` (for US letter) be translated to 8x11.5 inches (currently, only in
  chrome)

- `open_password` - requires `pdftk`, set password to encrypt PDFs with

- `edit_password` - requires `pdftk`, set password for edit permissions on PDF

- `shell_params` - pass custom parameters to `wkhtmltopdf` or `chrome-headless-render-pdf`. **CAUTION: BEWARE OF SHELL INJECTIONS!**

- `command_prefix`- prefix `wkhtmltopdf` with some command or a command with
  options (e.g. `xvfb-run -a`, `sudo` ..)

- `delete_temporary` - immediately remove temp files after generation

## Contribution

You're more than welcome to submit patches. Please run `mix test` to ensure at
bit of stability. Tests require a full-fledged environment, with all of
`wkhtmltopdf`, `xvfb` and `chrome-headless-render-pdf` available path. Also
make to to have run `npm install` in the app's base directory (will install
chrome-headless-render-pdf non-globally in there). With all these installed,
`mix test` should run smoothly.

_Hint_: Getting `:enoent` errors usually means that chrome or xvfb couldn't be
run. Yes, this should output a nicer error.

## Heroku Setup

If you want to use this project on Heroku, you can use buildpacks instead of
binaries to load `pdftk` and `wkhtmltopdf`:

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

If you want to run `wkhtmltopdf` with an unpatched version of webkit that requires
an X Window server, but your server (or Mac) does not have one installed,
you may find the `command_prefix` handy:

```elixir
PdfGenerator.generate "<html..", command_prefix: "xvfb-run"
```

This can also be configured globally in your `config/config.exs`:

```elixir
config :pdf_generator,
    command_prefix: "/usr/bin/xvfb-run"
```

If you will be generating multiple PDFs simultaneously, or in rapid succession,
you will need to configure `xvfb-run` to search for a free X server number,
or set the server number explicitly. You can use the `command_prefix` to pass
options to the `xvfb-run` command.

```elixir
config :pdf_generator,
    command_prefix: ["xvfb-run", "-a"]
```

## Documentation

For more info, read the [docs on hex](http://hexdocs.pm/pdf_generator) or issue
`h PdfGenerator.generate` in your iex shell.

## Known issues

Unfortunately, with Elixir 1.7+ `System.cmd` seems to pass parameters
differently to the environment than it did before, now requiring shell options
like `--foo=bar` to be split up as `["--foo", "bar"]`. This behaviour seemingly
went away with OTP 22 in May 2019 and Elixir 1.8.2. So if you run into issues,
try upgrading to the latest Erlang/OTP and Elixir first, and do not hesitate
file a report.

## Contributing

Contributions (Issues, PRs…) are more than welcome. Please have a quick read at
the [Contribution tips](./CONTRIBUTING.md), though. It's basically about scope
and kindness.

## Copyright and License

Copyright (c) 2014 Martin Gutsch

Released under the MIT License, which can be found in [LICENSE.md](./LICENSE.md).
