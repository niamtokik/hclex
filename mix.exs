defmodule Hclex.MixProject do
  use Mix.Project

  def project do
    [
      app: :hclex,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~>0.19.0"},
      {:proper, "~1.3.0"},
    ]
  end
end
