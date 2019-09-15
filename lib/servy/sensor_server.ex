defmodule Servy.SensorServer do
  @name :sensor_server
  use GenServer

  defmodule State do
    defstruct interval: 0, sensors: %{}
  end

  def start_link(interval) do
    IO.puts("\nStarting the Sensor server with #{interval} seconds refresh")

    GenServer.start_link(__MODULE__, %State{interval: interval}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  # Server Callbacks
  def init(state) do
    sensor_data = run_tasks_to_get_sensor_data()
    initial_state = %{state | sensors: sensor_data}
    schedule_refresh(state.interval)
    {:ok, initial_state}
  end

  def handle_info(:refresh, state) do
    IO.puts("Refreshing the cache...")
    sensor_data = run_tasks_to_get_sensor_data()
    new_state = %{state | sensors: sensor_data}
    schedule_refresh(state.interval)
    {:noreply, new_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_cast do
  end

  def schedule_refresh(interval) do
    IO.puts("Refreshing the state after #{interval} seconds.....")
    Process.send_after(self(), :refresh, :timer.seconds(interval))
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts("Running tasks to get sensor data")
    task = Task.async(fn -> Servy.Tracker.get_location("bmw") end)
    where_is_the_bmw = Task.await(task)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    %{snapshots: snapshots, location: where_is_the_bmw}
  end
end
