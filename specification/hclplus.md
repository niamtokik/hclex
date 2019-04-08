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

HCL+ wants to add more safety in configuration file by creating a
layer of specification and constraint. 

## HCL Specification

### Common symbols

```
digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
```

### Identifiers

```
identifier = { "_" | ascii_alphabet | unicode_alphabet | ascii_digit };
```

### Strings

```
string = '"', { unicode }, '"';
```

### Numbers

```
number = [ "-" ] digit | "." | "e" | "E" | "+" | "-" | digit;
```

### Lists

```
list = "[", string | number | list | block, "," ,"]";
```

### Blocks

```
block = "{", identifier, "=", string | number | list "}";
```

## HCL+ Specification

HCL+ add at least two new patterns in the HCL standard, a typing
syntax and a guard syntax. These two new components are dynamic and
add a way to control included data in configuration file.

### Typing Syntax

A type in HCL+ extend the common HCL type (string, identifier, number,
list and block) by giving the opportunity to build our own type from
scratch.

```
identifier :: type() = "value"
```

### Guard Syntax

A guard in HCL+ is a dynamic pattern to control the data contained in
a field. Guards are used to valid the content of the data.

```
identifier !! guard() = "value"
```

### Full Syntax Example

HCL+ as a configuration language

```
identifier :: type() !! guard() = "default_value"
```

HCL+ as a template language

```
```

HCL+ as a definition language

```
```

## Parsing

Implementing a parser is not a straight forward task and lot of things
can go wrong. Its why we want to create strongly separated components
and interconnected them with standard data-struture.

We are also using a language like Erlang or Elixir to easily
distribute the computation. Like everywhere, the key is the
communication and the way each components are talking together.

### Lexical Analysis

Lexical Analyzer part will generate tokens 

```
```

### Syntax Analysis

```
```

### Abstract Syntax Tree

```
```

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

## Glossary

## Notes

 * each identifier should be seen has a totally independent container
   containing all required information. HCL+ model can check all value
   in each container and ensuring if everything is working correctly.

## References

 * Modern Compiler Design
 * Modern Compiler Implementation in C
 * Crafting a Compiler
 * The Compiler Design Handbook
 * Engineering a Compiler
 * Algorithms on strings
 * Data Streams, Algorithms and Applications

## Ressources

 * https://json.org/
 * https://yaml.org/spec/
 * https://www.w3.org/TR/REC-xml/
 * https://en.cppreference.com/w/cpp/language/escape 
 * 

## Inspiration

 * https://coq.inria.fr/
 * https://lamport.azurewebsites.net/tla/tla.html
