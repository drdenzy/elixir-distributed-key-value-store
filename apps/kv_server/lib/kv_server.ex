defmodule KVServer do
  require Logger

  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes

    # [:binary, packet: :line, active: false, reuseaddr: true] is syntactic sugar for:
    # [:binary, {:packet, :line}, {:active, false}, {:reuseaddr, true}]
    #
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, {:packet, :line}, {:active, false}, {:reuseaddr, true}])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(KVServer.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket)
  end

  # defp serve(socket) do
  #   # The pipe operator (|>) evaluates the left side and passes its result as the `first argument` to the function on the right side.
  #   # Therefore: `socket |> read_line() |> write_line(socket)` is a syntactic sugar for: `write_line(read_line(socket), socket)`
  #   socket
  #   |> read_line()
  #   |> write_line(socket)

  #   serve(socket)
  # end

  # defp read_line(socket) do
  #   {:ok, data} = :gen_tcp.recv(socket, 0)
  #   data
  # end

  # defp write_line(line, socket) do
  #   :gen_tcp.send(socket, line)
  # end
  # 
  
  # defp serve(socket) do
  #   msg =
  #     case read_line(socket) do
  #       {:ok, data} ->
  #         case KVServer.Command.parse(data) do
  #           {:ok, command} ->
  #             KVServer.Command.run(command)
  #           {:error, _} = err ->
  #             err
  #         end
  #       {:error, _} = err ->
  #         err
  #     end
  
  #   write_line(socket, msg)
  #   serve(socket)
  # end
  
  defp serve(socket) do
    msg =
      with {:ok, data} <- read_line(socket),
           {:ok, command} <- KVServer.Command.parse(data),
           do: KVServer.Command.run(command)
  
    write_line(socket, msg)
    serve(socket)
  end
  
  
  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end
  
  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end
  
  defp write_line(socket, {:error, :not_found}) do
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end
  
  defp write_line(socket, {:error, :unknown_command}) do
    # Known error; write to the client
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end
  
  defp write_line(_socket, {:error, :closed}) do
    # The connection was closed, exit politely
    exit(:shutdown)
  end
  
  defp write_line(socket, {:error, error}) do
    # Unknown error; write to the client and exit
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
  

end
