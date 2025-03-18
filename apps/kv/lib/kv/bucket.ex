defmodule KV.Bucket do
  @moduledoc """
  A distributed key-value store backed by an Agent process.
  """

  use Agent, restart: :temporary

  @doc """
  Starts a new bucket process linked to the current process.
  
  ## Options
  See `Agent.start_link/2` for available options (e.g., `:name` for registration).
  """
  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  
  Returns `nil` if the key doesn't exist.
  """
  @spec get(agent :: pid(), key :: any()) :: any()
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  
  Overwrites existing values.
  """
  @spec put(agent :: pid(), key :: any(), value :: any()) :: :ok
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Merges a map of `updates` into the bucket.
  
  Existing keys are overwritten with new values.
  """
  @spec merge(agent :: pid(), updates :: map()) :: :ok
  def merge(bucket, updates) do
    Agent.update(bucket, &Map.merge(&1, updates))
  end

  @doc """
  Deletes the entry for `key` from the bucket.
  
  No-op if the key doesn't exist.
  """
  @spec delete(agent :: pid(), key :: any()) :: :ok
  def delete(bucket, key) do
    Agent.update(bucket, &Map.delete(&1, key))
  end
  
  @doc """
    Pops the entry for `key` from the bucket.
    
    returns nil if key does not exist otherwise returns the popped value.
    """
  def pop(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
