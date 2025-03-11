defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "basic CRUD operations", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3

    KV.Bucket.delete(bucket, "milk")
    assert KV.Bucket.get(bucket, "milk") == nil
  end

  test "merge functionality", %{bucket: bucket} do
    KV.Bucket.put(bucket, :a, 1)
    KV.Bucket.merge(bucket, %{a: 2, b: 3})

    assert KV.Bucket.get(bucket, :a) == 2
    assert KV.Bucket.get(bucket, :b) == 3
  end

  test "delete non-existent key", %{bucket: bucket} do
    assert KV.Bucket.delete(bucket, :ghost) == :ok
    assert KV.Bucket.get(bucket, :ghost) == nil
  end
  
  test "pop an existing key from bucket", %{bucket: bucket} do
    KV.Bucket.put(bucket, "milk", 3)
    assert 3 == KV.Bucket.pop(bucket, "milk")
  end
  
  test "pop a non-existent key from bucket", %{bucket: bucket} do
    assert KV.Bucket.pop(bucket, :ghost) == nil
  end

  test "concurrent updates", %{bucket: bucket} do
    tasks =
      for x <- 1..100 do
        Task.async(fn -> KV.Bucket.put(bucket, :counter, x) end)
      end

    Task.await_many(tasks)
    assert is_integer(KV.Bucket.get(bucket, :counter))
  end
end
