elixir-pdf-generator
====================

A simple wrapper for wkhtmltopdf (HTML to PDF) for use in Elixir projects.
It is currently using temporary files instead of pipes or other means of IPC.

Usage
=====
Download wkhtmltopdf and place it in your $PATH. Current binaries can be found here:
http://wkhtmltopdf.org/downloads.html

For best results, download goon and place it yout $PATH. Current binaries can be found here:
https://github.com/alco/goon/releases

Add this to your dependencies in your mix.exs:

    defp deps do
        [
            # ... whatever else
            {:pdf_generator, github: "gutschilla/elixir-pdf-generator", branch: "master" },
        ]
    end


Then pass some html to PDFGenerator.generate

    html = "<html><body><p>Hi there!</p></body></html>"
    # be aware, this may take a while...
    file_name = PDFGenerator.generate( html )
    {:ok, pdf_content } = File.read( file_name )

TODO
====

[ ] Use porcelain's/goon's direct IPC feature to remove the creation of intermediate tmp files.
[ ] Pass some useful base path so wkhtmltopdf can resolve static files (styles, images etc) linked in the HTML
