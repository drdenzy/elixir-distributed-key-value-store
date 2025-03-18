defmodule MyRemote do
  def hello do
    IO.puts("Hello from #{inspect(Node.self())}")
  end
end