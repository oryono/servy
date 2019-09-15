defmodule Servy.KickStarter do
  use GenServer

  def start_link(_args) do
    IO.puts("Starting the kick Starter....")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    IO.puts("Starting the HTTP Server....")
    port = Application.get_env(:servy, :port)
    server_pid = spawn(Servy.HTTPServer, :start, [port])
    Process.link(server_pid)
    Process.register(server_pid, :http_server)
    {:ok, server_pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HTTP Server exited #{inspect(reason)}")
    server_pid = spawn(Servy.HTTPServer, :start, [4000])
    Process.link(server_pid)
    Process.register(server_pid, :http_server)
    {:noreply, server_pid}
  end
end
