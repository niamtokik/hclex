# HCL+ Specification

Hashicorp Configuration Language is the defacto-standard for a lot of
application like terraform, consul and many more. Based on UCL and
Nginx configuration syntax, it gives an easy way to create readable
and maintenable configuration.

HCL+ wants to add a layer on this language by adding more control
features like typing. HCL+ will act as a model descriptive language by
adding a new way of specifying configuration.

## Introduction

wip

## Why HCL+

wip

## Shared HCL Specification

wip

## HCL+ Specification

wip

### Typing Syntax

wip

```
identifier :: type() = "value"
```

### Guard Syntax

wip

```
identifier !! guard() = "value"
```

### Full Syntax Example

wip

```
identifier :: type() !! guard() = "default_value"
```

## Parsing

wip

### Scanner

wip

### Lexer

wip

### AST

wip

## JSON Export

wip

```
{
  "identifier" = "value",
  "::type" = "type()",
  "!!guard" = "guard()"
}

```

## YAML Export

wip

```
```

## XML Export

wip

```
```

## Notes

 * each identifier should be seen has a totally independent container
   containing all required information. HCL+ model can check all value
   in each container and ensuring if everything is working correctly.

## Inspiration

 * https://coq.inria.fr/
 * https://lamport.azurewebsites.net/tla/tla.html
