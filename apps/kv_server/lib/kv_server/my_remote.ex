defmodule MyRemote do
  @moduledoc """
  Distributed node verification module with multiple execution checks.
  
  Usage:
  1. On both nodes: Node.spawn(remote_node, MyRemote, :full_report, [])
  2. On both nodes: MyRemote.whereis(pid)
  """

  @doc "Prints comprehensive system info from execution node"
  def full_report do
    hostname = System.cmd("hostname", []) |> elem(0) |> String.trim()
    os = os_name()
    node = inspect(Node.self())
    
    IO.puts("""
    === System Report ===
    Hostname: #{hostname}
    OS: #{os}
    Node: #{node}
    MAC Machine? #{is_mac?()}
    Lenovo Machine? #{is_lenovo?()}
    Local Service Check: #{check_local_service()}
    =====================
    """)
  end

  @doc "Returns true if running on Mac hardware"
  def is_mac? do
    case :os.type() do
      {:unix, :darwin} -> true
      _ -> String.contains?(hostname(), "Denniss-MacBook-Pro")
    end
  end

  @doc "Returns true if running on Lenovo hardware"
  def is_lenovo? do
    case :os.type() do
      {:unix, :linux} -> 
        String.contains?(hostname(), "linux") || 
        String.contains?(hostname(), "ubuntu")
      _ -> false
    end
  end

  @doc "Returns normalized OS name"
  def os_name do
    case :os.type() do
      {:unix, :darwin} -> "macOS"
      {:unix, :linux} -> "Linux"
      _ -> "Unknown"
    end
  end

  @doc "Verifies network-accessible local services"
  def check_local_service do
    case System.cmd("ping", ["-c", "1", "lenovo-local-hostname"]) do
      {_, 0} -> "Connected to Lenovo-local service"
      _ -> "No Lenovo-local service found"
    end
  end

  @doc "Identifies location of a process"
  def whereis(pid) do
    case Node.connect(Node.self()) do
      true -> 
        case Process.info(pid, :registered_name) do
          {:registered_name, name} -> "Process registered on #{Node.self()} as #{name}"
          _ -> "Anonymous process on #{Node.self()}"
        end
      false -> "Process located on remote node: #{inspect(Node.self())}"
    end
  end

  defp hostname do
    System.cmd("hostname", []) |> elem(0) |> String.downcase()
  end
end