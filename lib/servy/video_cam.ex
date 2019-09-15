defmodule Servy.VideoCam do
  @doc """
  Simulates sending an API request to an external server to get snapshot image from an external server
  """
  def get_snapshot(camera_name) do
    # We send api request
    # Sleep for a second to simulate slow networl

    :timer.sleep(1000)
    "#{camera_name}-snapshot-#{:rand.uniform(1000)}.jpg"
  end
end
