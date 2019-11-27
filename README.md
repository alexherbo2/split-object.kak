# Split Object

**Status** – _Maintained_ – Until [#138]

[![IRC][IRC Badge]][IRC]
[![Discuss][Discuss Badge]][Discuss]

###### [Usage](#usage) | [Documentation](#modes) | [Contributing](CONTRIBUTING)

> Fork of alexherbo2's split object for [Kakoune] with better handling of exceptions.

[![asciicast](https://asciinema.org/a/239870.svg)](https://asciinema.org/a/239870)

## Installation

### [Plug]

``` kak
plug ZakharEl/split-object.kak
```
in kakrc & then in kakoune editor issue the command plug-install

## Usage

``` kak
map global normal <a-I> ': enter-user-mode split-object<ret>'
```

## Modes

- `split-object`

## Objects

- `b`, `(`, `)`: Parenthesis block
- `B`, `{`, `}`: Braces block
- `r`, `[`, `]`: Brackets block
- `a`, `<`, `>`: Angle block
- `Q`, `"`: Double quote string
- `q`, `'`: Single quote string
- `g`, `` ` ``: Grave quote string
- `w`: Word
- `<a-w>`: Big word
- `s`: Sentence
- `p`: Paragraph
- `c`: Custom object description

[#138]: https://github.com/mawww/kakoune/issues/138
[Kakoune]: https://kakoune.org
[IRC]: https://webchat.freenode.net/#kakoune
[IRC Badge]: https://img.shields.io/badge/IRC-%23kakoune-blue.svg
[Discuss]: https://discuss.kakoune.com/t/ability-to-split-object-selections/442
[Discuss Badge]: https://img.shields.io/badge/Discuss-442-green.svg
[Plug]: https://github.com/andreyorst/plug.kak
