defmodule Servy.HTTPServer do
  @doc """
  Starts the server on a given port of localhost
  """
  def start(port) when is_integer(port) and port > 1023 do
    # Creates a socket to listen for client connections

    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    IO.puts("\n 🎧 Listening for connection requests on port #{port}....\n")
    accept_loop(listen_socket)
  end

  @doc """
  Accepts connections on the listen socket
  """
  def accept_loop(listen_socket) do
    IO.puts("⏳ Waiting to accept a client connection....\n")
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts("⚡️ Connection accepted. \n")
    # Receives request and sends response
    spawn(fn -> serve(client_socket) end)

    # Loop back to wait and accept next connection
    accept_loop(listen_socket)
  end

  @doc """
  Receives request on the client socket and sends it back over the same socket
  """
  def serve(client_socket) do
    IO.puts("#{inspect(self())} working on it")

    client_socket
    |> read_request
    |> Servy.Handler.handle()
    |> write_response(client_socket)
  end

  @doc """
  Receives request on the client socket
  """
  def read_request(client_socket) do
    # All available bytes
    {:ok, request} = :gen_tcp.recv(client_socket, 0)

    IO.puts("Request Received \n")
    IO.inspect(request)

    request
  end

  @doc """
  Returns generic response
  """
  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  @doc """
  Sends the response over the client socket
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts("Sent response \n")
    IO.puts(response)

    # closes the client socket, ending the connection
    # doesn't close the listen socket
    :gen_tcp.close(client_socket)
  end
end
