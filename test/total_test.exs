defmodule TestModule do
  require Total

  Total.defunion(binary_digit() :: :zero | :one)
end

defmodule TotalTest do
  use ExUnit.Case
  doctest Total
  require TestModule

  Total.defunion(order() :: :gt | :eq | :lt)
  Total.defunion(result() :: {:ok, term()} | {:error, term()})

  test "@type is defined" do
    assert [result, order] = @type
    assert {:type, {:::, _, [{:result, _, []}, {:|, _, [{:ok, _}, {:error, _}]}]}, _} = result
  end

  test "ok" do
    order_case :gt do
      _ -> :ok
      :eq -> flunk("no")
      :lt -> flunk("no")
    end

    result_case {:ok, 1} do
      {:other, _, _} -> flunk("no")
      {:ok, _} -> :ok
      {:error, _} -> flunk("no")
    end

    TestModule.binary_digit_case :zero do
      :zero -> :ok
      :one -> :ok
    end
  end
end
