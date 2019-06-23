# Total

Simple exhaustiveness checking of tuple + atom based unions.

```elixir
defmodule MyType do
  require Total

  # define a union
  Total.defunion(method() :: :get | :post | {:other, term()})
end

defmodule Elsewhere do
  require MyType

  # This is OK, all variants are covered
  def method_string(m) do
    MyType.method_case m do
      :get -> "GET"
      :post -> "POST"
      {:other, t} -> t
    end
  end

  # This is a compile time error: missing `{:other, term()}`
  def method_string(m) do
    MyType.method_case m do
      :get -> "GET"
      :post -> "POST"
    end
  end
end
```

The exhaustiness checking is very basic: bare atoms are checked and tuples
have their tag and length checked, but their arguments are unchecked.

All other terms and guard clauses are ignored.


## Installation

```elixir
def deps do
  [
    {:total, "~> 0.1.0"}
  ]
end
```
