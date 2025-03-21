defmodule KV.RouterTest do
  use ExUnit.Case
  
  setup_all do
      current = Application.get_env(:kv, :routing_table)
  
      Application.put_env(:kv, :routing_table, [
        {?a..?m, :"lenovo_node@10.0.0.239"},
        {?n..?z, :"mac_node@Denniss-MacBook-Pro.local"}
      ])
  
      on_exit fn -> Application.put_env(:kv, :routing_table, current) end
    end
  
    @tag :distributed

  @tag :distributed
  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) == :"lenovo_node@10.0.0.239"
    assert KV.Router.route("world", Kernel, :node, []) == :"mac_node@Denniss-MacBook-Pro.local"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
