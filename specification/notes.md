# HCL source code notes

## Scanner


https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L84
:If an invalid UTF8 character is present, the parser return an error
`illegal UTF-8 encoding`.

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L89
:if a new line character is present, line state is incremented.

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L95
:a null char (`\x00`) return an error `unexpected null character
(0x00)`.

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L100
:`\uE123` utf8 character return an error `unicode code point U+E123
reserved for internal use`.

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L159
:check if the character is a letter

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L165
:check if the chacter is a digit

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L169
:`EOF` end of the file section

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L171
:`"` is a string

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L174
:check if the character is `#` or `/` and check if the rest is a
comment (one line)

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L177
:check if character is `.` is in a digit (or not)

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L185
:check if character is `<`, and send the rest to heredoc.

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L188
:check if character is `[`

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L190
:check if character is `]`

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L192
:check if character is `{`

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L194
:check if character is `}`

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L196
:check if character is `,`

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L198
:check if character is `=`

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L200
:check if character is `+`

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L202
:check if character is `-`

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L209
:if not a defined pattern, return an error `illegal char`.

## Comments

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L231

## Numbers

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L272

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L357


## Strings

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L477

## Strings (HEREDOC)

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L395
:check if the next character is `<` 

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L407
:indented heredoc syntax if next char is `-`

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L422
:windows new line support

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L429
:HEREDOC must end with `\n`.

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L435
:if HEREDOC identifier is null, return an error `zero-length heredoc
anchor`.

## Escape characters

https://github.com/niamtokik/hcl/blob/master/hcl/scanner/scanner.go#L513





 
