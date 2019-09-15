defmodule Servy.GenericServer do
  def start(callback_moudle, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_moudle])
    Process.register(pid, name)
  end

  def call(pid, message) do
    send(pid, {self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, message)
  end

  def listen_loop(state, callback_module) do
    receive do
      {sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      message ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        IO.puts("Unexpected message #{unexpected}")
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.PledgeServerHandRolled do
  alias Servy.GenericServer
  @name :pledge_server_hand_rolled
  def start do
    IO.puts("\nStarting the pledge server")
    GenericServer.start(__MODULE__, [], @name)
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)

    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end

  def handle_cast(:clear, _state) do
    []
  end

  def create_pledge(name, amount) do
    GenericServer.call(@name, {:create_pledge, name, amount})
  end

  def clear() do
    GenericServer.cast(@name, :clear)
  end

  def recent_pledges() do
    #   Returns the most recent pledges
    GenericServer.call(@name, :recent_pledges)
  end

  #    Helper functions

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "Pledge-#{:rand.uniform(1000)}"}
  end
end

# Servy.PledgeServerHandRolled.start()

# IO.inspect(Servy.PledgeServerHandRolled.create_pledge("Patrick", 10))
# IO.inspect(Servy.PledgeServerHandRolled.create_pledge("Patricia", 10))
# IO.inspect(Servy.PledgeServerHandRolled.create_pledge("Annet", 20))
# IO.inspect(Servy.PledgeServerHandRolled.create_pledge("Derrick", 40))
# Servy.PledgeServerHandRolled.clear()
# IO.inspect(Servy.PledgeServerHandRolled.create_pledge("Scovia", 50))

# IO.inspect(Servy.PledgeServerHandRolled.recent_pledges())
