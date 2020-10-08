defmodule ArcCloudinary.MixProject do
  use Mix.Project

  def project do
    [
      app: :arc_cloudinary,
      version: "0.0.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: description(),
      package: package()
    ]
  end

  defp description do
    """
    Provides Cloudinary storage backend for Arc.
    """
  end

  defp package do
    [
      maintainers: ["Erickson Gitahi"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/_r.coh/arc_cloudinary"},
      files: ~w(mix.exs README.md lib config)
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:cloudex, "~> 1.4"},
      {:arc, "~> 0.11.0"},
      {:ex_doc, "~> 0.22.6", only: :dev}
    ]
  end
end
