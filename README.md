elixir-pdf-generator
====================

A simple wrapper for wkhtmltopdf (HTML to PDF) and PDFTK (adds in encryption) for use in Elixir projects.
It is currently using temporary files instead of pipes or other means of IPC.

Changes
=======
 - 0.2.0 
  - adding support for PDFTK to create encrypted PDFs
  - **API-CHANGE** PdfGenerator.generate now returns tuple `{ :ok, file_name }`
    instead of just `file_name`
  - Adding some docs, issue `h PdfGenerator` in your iex shell for more info

Usage
=====
Download wkhtmltopdf and place it in your $PATH. Current binaries can be found here:
http://wkhtmltopdf.org/downloads.html

For best results, download goon and place it yout $PATH. Current binaries can be found here:
https://github.com/alco/goon/releases

Install pdftk via your package manager or homebrew. The project page also contains a Windows installer

Add this to your dependencies in your mix.exs:

    defp deps do
        [
            # ... whatever else
            { :pdf_generator, "0.2.0" },
        ]
    end


Then pass some html to PDFGenerator.generate

```
html = "<html><body><p>Hi there!</p></body></html>"
# be aware, this may take a while...
{ :ok, file_name } = PDFGenerator.generate html, page_size: "A5", open_password: "s3cr3t" 
{ :ok, pdf_content } = File.read file_name 
```

For more info, read the docs or issue `h PdfGenerator.generate` in your iex shell

TODO
====

- [ ] Use porcelain's/goon's direct IPC feature to remove the creation of intermediate tmp files.
- [ ] Pass some useful base path so wkhtmltopdf can resolve static files (styles, images etc) linked in the HTML
