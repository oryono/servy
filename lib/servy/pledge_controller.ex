defmodule Servy.PledgesController do
  def create(conv, %{"name" => name, "amount" => amount}) do
    Servy.PledgeServer.create_pledge(name, String.to_integer(amount))
    %{conv | status_code: 201, response_body: "#{name} pledged #{amount}"}
  end

  def index(conv) do
    pledges = Servy.PledgeServer.recent_pledges()
    IO.puts("Here we have #{inspect(pledges)}")
    %{conv | status_code: 200, response_body: inspect(pledges)}
  end
end
