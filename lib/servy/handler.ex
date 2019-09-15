defmodule Servy.Handler do
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  alias Servy.Conv
  alias Servy.NameController

  @pages_path Path.expand("pages")

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  # def route(conv) do
  #   # conv = Map.put(conv, response_body: "Bears, Lions, Tigers") Alternative method
  #   # %{conv | response_body: "Bears, Lions, Tigers"}

  #   route(conv, conv.path)
  # end

  def route(%Conv{path: "/kaboom", method: "GET"}) do
    raise "Kaboom"
  end

  def route(%Conv{path: "/pledges", method: "POST"} = conv) do
    Servy.PledgesController.create(conv, conv.params)
  end

  def route(%Conv{path: "/pledges", method: "GET"} = conv) do
    Servy.PledgesController.index(conv)
  end

  def route(%Conv{path: "/sensors"} = conv) do
    sensor_data = Servy.SensorServer.get_sensor_data()
    %{conv | status_code: 200, response_body: inspect(sensor_data)}
  end

  def route(%Conv{path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()

    %{conv | status_code: 200, response_body: "Awake"}
  end

  def route(%Conv{path: "/something"} = conv) do
    %{conv | status_code: 200, response_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{path: "/names", method: "GET"} = conv) do
    NameController.list_all(conv)
  end

  def route(%Conv{path: "/names", method: "POST"} = conv) do
    %{
      conv
      | status_code: 201,
        response_body: "Created a name #{conv.params["name"]} with age #{conv.params["age"]}"
    }
  end

  def route(%Conv{path: "/waters"} = conv) do
    %{conv | status_code: 200, response_body: "Rwenzori, Highland"}
  end

  # def route(%{path: "/about"} = conv) do
  #   file =
  #     Path.expand("pages")
  #     |> Path.join("about.html")

  #   IO.puts(file)

  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{conv | status_code: 200, response_body: content}

  #     {:error, :enoent} ->
  #       %{conv | status_code: 404, response_body: "File not found"}

  #     {:error, reason} ->
  #       %{conv | status_code: 500, response_body: "Something went wrong"}
  #   end
  # end

  def route(%Conv{path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status_code: 404, response_body: "Path #{path} is missing"}
  end

  defp handle_file({:ok, content}, conv) do
    %{conv | status_code: 200, response_body: content}
  end

  defp handle_file({:error, :enoent}, conv) do
    %{conv | status_code: 404, response_body: "File not found"}
  end

  defp handle_file({:error, reason}, conv) do
    %{conv | status_code: 404, response_body: "Something went wrong: #{reason}"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.response_body)}

    #{conv.response_body}
    """
  end
end

# request = """
# GET /something HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)

# IO.puts(response)

# request = """
# GET /names HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)

# IO.puts(response)

# request = """
# GET /waters HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)

# IO.puts(response)

# request = """
# GET /bigfoot HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)

# IO.puts(response)

# request = """
# GET /about HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)

# IO.puts(response)

# request = """
# POST /names HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: application/x-www-form-url-encoded
# Content-Length: 21

# name=Patrick Oryono&age=26
# """

# response = Servy.Handler.handle(request)

# IO.puts(response)
