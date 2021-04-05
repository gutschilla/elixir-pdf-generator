# Contributing

Everyone is invited to contribute to this project.

**A BIG THANK YOU** to all of those who already made this project more helpful for everyone.

# Scope

This project is only about generating PDFs from HTML. That HTML can come from either
a string (the HTML itself) or a URL (the body of a GET request to that URL).
Other sources can be SVG (both Chrome and wkhtmltopdf support this), JPEG or
anything else that a Webkit-based Browser would display and print to a PDF.

Anything else like preprocessing the input (HTML templating) or postprocessing the PDF
(moving it somewhere, glueing it together with other PDFs) apart from encryption
(currently done via PDFTK) is not in scope of this project.

See https://github.com/gutschilla/elixir-pdf-server for an example of how to include
more functionality by just _importing_ this project.

# Maintainer's duties

1. I will try hard to review every PR or issue in a timely manner (within a few
   business days, unless I am on vacations). I am a father, husband and do have a
   day job so please do not expect ultra-immediate responses.
2. I will give usable feedback for why I won't accept a PR

# A kind request to contributors

- for any contribution, describe your intentions first
- if possible, provide tests and documentation with your PR
- if possible, come up with a PR in the first place
- comply with https://github.com/christopheradams/elixir_style_guide (I am not dogmatic about this one)
- be kind and helpful to everyone as I am trying hard to be as well

# On bug reports

- Until now, I didn't feel anyone was unkind or offensive
- nor was anybody looking for me to fix his/her code

While this stays that way, I feel there's no need to enforce good manners :-)
