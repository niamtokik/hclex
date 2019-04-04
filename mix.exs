defmodule Hclex.MixProject do
  use Mix.Project

  def project do
    [
      app: :hclex,
      deps: deps(),
      description: description(),
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0",
      name: "hclex",
      source_url: "https://github.com/niamtokik/hclex",
      homepage_url: "https://github.com/niamtokik/hclex",
      docs: [
	extras: ["README.md", "specification/hclplus.md"]
      ]
    ]
  end

  defp description do
    "hclex is an implementation of Hashicorp Configuration Language in pure Elixir."  
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~>0.19.0"},
      {:proper, "~>1.3.0"},
      {:unicode, "~> 1.0.0"}
    ]
  end
  
end
