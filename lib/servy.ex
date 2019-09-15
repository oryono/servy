defmodule Servy do
  use Application

  @moduledoc """
  Documentation for Servy.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Servy.hello()
      :world

  """
  def start(_type, _args) do
    IO.puts("Starting the Application")
    Servy.Supervisor.start_link()
  end
end
