defmodule Servy.PledgeServer do
  @name :pledge_server
  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  def start_link(_args) do
    IO.puts("\nStarting the pledge server....")
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def init(state) do
    pledges = get_recent_pledges_from_external_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)

    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_info(message, state) do
    IO.puts("Can't touch this #{inspect(message)}")
    {:noreply, state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    new_state = %{state | cache_size: size}
    {:noreply, new_state}
  end

  def set_cache_size(size) do
    GenServer.cast(@name, {:set_cache_size, size})
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def clear() do
    GenServer.cast(@name, :clear)
  end

  def recent_pledges() do
    #   Returns the most recent pledges
    GenServer.call(@name, :recent_pledges)
  end

  #    Helper functions

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "Pledge-#{:rand.uniform(1000)}"}
  end

  defp get_recent_pledges_from_external_service() do
    # This would happen here.

    [{"Wilma", 15}, {"Karo", 100}]
  end
end

# {:ok, pid} = Servy.PledgeServer.start()
# send(pid, {:stop, "Hammertime"})
# # Servy.PledgeServer.set_cache_size(4)
# IO.inspect(Servy.PledgeServer.create_pledge("Patrick", 10))
# # Servy.PledgeServer.clear()
# # IO.inspect(Servy.PledgeServer.create_pledge("Patricia", 10))
# # IO.inspect(Servy.PledgeServer.create_pledge("Annet", 20))
# # IO.inspect(Servy.PledgeServer.create_pledge("Derrick", 40))

# # IO.inspect(Servy.PledgeServer.create_pledge("Scovia", 50))

# IO.inspect(Servy.PledgeServer.recent_pledges())
