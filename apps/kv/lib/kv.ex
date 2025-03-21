defmodule KV do
  use Application
  @moduledoc """
  Documentation for `KV`.
  """
  
  @impl true 
  def start(_type, _args) do 
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    KV.Supervisor.start_link(name: KV.Supervisor)
  end
end
