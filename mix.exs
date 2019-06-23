defmodule Total.MixProject do
  use Mix.Project

  def project do
    [
      app: :total,
      version: "0.1.0",
      elixir: "~> 1.8",
      name: "total",
      description: "Basic exhaustiveness checking of unions.",
      start_permanent: Mix.env() == :prod,
      package: [
        maintainers: ["Louis Pilfold"],
        licenses: ["apache-2.0"],
        links: %{"GitHub" => "https://github.com/lpil/total"},
        files: ~w(LICENCE README.md lib mix.exs)
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Automatic test runner
      {:mix_test_watch, "~> 0.4", [only: :dev, runtime: false]},
      # Markdown processor
      {:earmark, "~> 1.2", [only: :dev, runtime: false]},
      # Documentation generator
      {:ex_doc, "~> 0.15", [only: :dev, runtime: false]}
    ]
  end
end
