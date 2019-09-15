defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, param_string] = String.split(request, "\r\n\r\n")
    [request_line | header_lines] = String.split(top, "\r\n")

    IO.puts("Headers: #{inspect(header_lines)}")

    headers = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], param_string)

    [method, path, _] = request_line |> String.split(" ")

    %Conv{method: method, path: path, headers: headers, params: params}
  end

  def parse_params("application/x-www-form-urlencoded", param_string) do
    param_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

  def parse_headers([head | tail], headers) do
    IO.puts("head: #{inspect(head)} Tail: #{inspect(tail)}")
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers) do
    IO.puts("Done")
    headers
  end
end
