defmodule Servy.Conv do
  defstruct method: "", status_code: nil, path: "", response_body: "", params: %{}, headers: %{}

  def full_status(conv) do
    "#{conv.status_code} #{status_reason(conv.status_code)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      404 => "Not Found",
      401 => "Unauthorized",
      403 => "Forbidden",
      500 => "Internal Server Error"
    }[code]
  end
end
