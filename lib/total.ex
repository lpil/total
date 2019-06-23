defmodule Total do
  @moduledoc """
  Basic exhaustiveness checking for Elixir applications.
  """

  @doc """
  Define a union type consisting of tagged-tuples and/or atoms.

      Total.defunion http_method() :: :get | :post | {:other, term()}
  """
  defmacro defunion(definition) do
    {:::, _, [{name, _, _}, variants]} = definition

    quote do
      @type unquote(definition)

      defmacro unquote(:"#{name}_case")(subject, do: clauses) do
        Total.build_case!(
          unquote(name),
          __CALLER__.file,
          __CALLER__.line,
          subject,
          unquote(Macro.escape(get_variants(variants), prune_metadata: true)),
          clauses
        )
      end
    end
  end

  @doc false
  def build_case!(name, file, line, subject, variants, clauses) do
    patterns =
      for {:->, _, [[pattern], _]} <- clauses do
        pattern
      end

    variants
    |> Enum.filter(fn type -> not Enum.any?(patterns, &covers?(&1, type)) end)
    |> case do
      [] ->
        {:case, [], [subject, [do: clauses]]}

      unmatched ->
        raise(Total.NonExhaustiveCase, {name, file, line, unmatched})
    end
  end

  @doc false
  defp covers?(pattern, variant) do
    case {pattern, variant} do
      # Atoms
      {_, _} when is_atom(pattern) ->
        pattern == variant

      # Variable pattern
      {{_var, _, nil}, _} ->
        true

      # Tuples of size 2
      {{pattern_tag, _}, {variant_tag, _}} ->
        pattern_tag == variant_tag

      # Tuples of other sizes
      {{:{}, _, [pattern_tag | pattern_args]}, {:{}, _, [variant_tag | variant_args]}} ->
        pattern_tag == variant_tag && length(pattern_args) == length(variant_args)

      # Other
      _ ->
        false
    end
  end

  defp get_variants(variants) do
    case variants do
      {:|, _, [variant, rest]} -> [variant | get_variants(rest)]
      variant -> [variant]
    end
  end
end

defmodule Total.NonExhaustiveCase do
  defexception [:message]

  def exception({name, file, line, unhandled}) do
    list_doc =
      unhandled
      |> Enum.map(&"    * #{Macro.to_string(&1)}")
      |> Enum.join("\n")

    source =
      file
      |> File.read!()
      |> String.split("\n")
      |> Enum.at(line - 1)

    padd = line |> to_string |> String.replace(~r/./, " ")

    message = """


    #{IO.ANSI.red()}Error#{IO.ANSI.reset()}: Non exhaustive patterns
    #{IO.ANSI.blue()}#{file}
    #{padd} |
    #{line} |#{IO.ANSI.reset()}#{source}
    #{IO.ANSI.blue()}#{padd} |#{IO.ANSI.reset()}

    The following variants of the `#{name}` union are not handled:

    #{IO.ANSI.yellow()}#{list_doc}#{IO.ANSI.reset()}

    Add new clauses to the `#{name}_case` to match these.
    """

    %__MODULE__{message: message}
  end
end
