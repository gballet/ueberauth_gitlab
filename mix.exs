defmodule UeberauthGitlab.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :ueberauth_gitlab,
     version: @version,
     name: "Ueberauth Gitlab",
     package: package(),
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/gballet/ueberauth_gitlab",
     homepage_url: "https://github.com/gballet/ueberauth_gitlab",
     description: description(),
     deps: deps(),
     docs: docs()]
  end

  def application do
    [applications: [:logger, :ueberauth, :oauth2]]
  end

  defp deps do
    [
        {:oauth2, "~> 0.8.2"},
        {:ueberauth, "~> 0.4"},
        {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp docs do
      [extras: ["README.md"]]
  end

  defp description do
      "An Ueberauth strategy for gitlab"
  end

  defp package do
      [files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Guillaume Ballet"],
      license: ["Unlicense"],
      links: %{"GitHub": "https://github.com/gballet/ueberauth_gitlab"}]
  end
end
