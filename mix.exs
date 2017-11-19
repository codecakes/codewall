defmodule Codewall.Mixfile do
  use Mix.Project

  def project do
    [
      app: :codewall,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:imagineer, "~> 0.3.0"},
      {:flow, "~> 0.12.0"},
      {:xml_builder, "~> 0.1.1"}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
