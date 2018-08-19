defmodule Clamxir.MixProject do
  use Mix.Project

  def project do
    [
      app: :clamxir,
      version: "0.1.2",
      elixir: "~> 1.7.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Clamav wrapper."
  end

  defp package do
    # These are the default files included in the package
    [
      name: :clamxir,
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Ruben Amortegui"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ramortegui/clamxir"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end
end
