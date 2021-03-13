defmodule AppWeb.ExampleLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    # ...
    {:ok, socket}
  end

  #...

  def handle_event("generate_pdf", _params, %{assigns: assigns} = socket) do
    # Passing the assigns to the method, so that the liveview render method can populate the template
    generate_pdf(assigns)
    {:noreply, socket}
  end

  def generate_pdf(assigns) do
    # Assuming you have a stylesheet applied on the root template, you'll need to include this stylesheet
    # in the rendered LiveView HTML
    style = """
      <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.css">
      <link rel="stylesheet" href='/css/app.css'/>
    """
    AppWeb.ExampleLive.render(assigns)
    |> Phoenix.HTML.Safe.to_iodata()
    |> List.to_string()
    |> Kernel.<>(style)
    |> PdfGenerator.generate!(page_size: "A4", generator: :chrome, prefer_system_executable: true)
  end
end
