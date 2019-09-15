defmodule Servy.NameController do
  alias Servy.Names

  @templates_path Path.expand("templates")

  IO.puts("@@@@@@@@@@")
  IO.puts("@@@@@@@@@@")
  IO.puts("Templates path #{@templates_path}")
  IO.puts("@@@@@@@@@@")
  IO.puts("@@@@@@@@@@")

  def list_all(conv) do
    names = [
      %Names{name: "Patrick Oryono", age: 26},
      %Names{name: "Scovia Akwii", age: 24},
      %Names{name: "Patricia Awilli", age: 24},
      %Names{name: "Lydia Akech", age: 21},
      %Names{name: "Christine Achieng", age: 23}
    ]

    names =
      names
      |> Enum.filter(fn n -> n.age < 25 end)
      |> Enum.sort(fn n1, n2 -> n1.name < n2.name end)

    content = @templates_path |> Path.join("index.eex") |> EEx.eval_file(names: names)

    %{conv | status_code: 200, response_body: content}
  end
end
