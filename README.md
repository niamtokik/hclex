# Hclex

`hclex` is a full implementation of the Hashicorp Configuration
Language in pure Elixir. This version also include a new one with more
feature based on the same specification and totally compatible with
the original one.

## Purpose and objectives

 * Full support of HCL
 * Simple pipeline
 * Simple AST
 * (HCL+) Adding static typing
 * (HCL+) Adding high level typing

## HCL Syntax Example

This support the whole HCL standard.

```
resource "name" "value" {
  identifier = "value"
}

```

## HCL+ Syntax Example

HCL+ is an extension of the HCL standard syntax by adding typing to
configuration file. You can see it as a template and protective
language against configuration mistake. This language is a work in
progress and does not have any specification written.

```
resource :: string() "name" "value" {
  identifier :: string() = "value"
}

resource :: string() "name" "value" {
  identifier !! guard(request) = "value"
}

resource :: string() "name" "value" {
  identifier :: string() !! regex() = "value"
}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be
installed by adding `hclex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hclex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with
[ExDoc](https://github.com/elixir-lang/ex_doc) and published on
[HexDocs](https://hexdocs.pm). Once published, the docs can be found
at [https://hexdocs.pm/hclex](https://hexdocs.pm/hclex).

## Testing

```elixir
mix test
```

## Documentation

```elixir
mix docs
```

## References

 * https://docs.hashicorp.com/sentinel/language/spec
 * https://www.linode.com/docs/applications/configuration-management/introduction-to-hcl/
 * https://www.terraform.io/docs/configuration/syntax.html
 * https://github.com/hashicorp/hcl/
 * https://github.com/vstakhov/libucl
