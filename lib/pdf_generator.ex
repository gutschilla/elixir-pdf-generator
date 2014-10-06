defmodule PdfGenerator do

    use Application

    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    def start(_type, _args) do
        import Supervisor.Spec, warn: false

        children = [
          # Define workers and child supervisors to be supervised
          # worker(TestApp.Worker, [arg1, arg2, arg3])
        ]

        opts = [strategy: :one_for_one, name: PdfGenerator.Supervisor]
        Supervisor.start_link(children, opts)
    end

    # return file name of generated pdf
    # requires: Porcelain, Random
    def generate( html ) do
        generate html, %{}
    end

    def generate( html, options ) do
        alias Porcelain.Result
        program = System.find_executable("wkhtmltopdf")
        html_file = Path.join System.tmp_dir, Random.string <> ".html"
        File.write html_file, html
        pdf_file  = Path.join System.tmp_dir, Random.string <> ".pdf"
        %Result{out: output, status: status} = Porcelain.exec(
            program, [ html_file, pdf_file ]
        )
        pdf_file
    end
end
