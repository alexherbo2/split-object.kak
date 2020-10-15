# split-object.kak

[Kakoune] plugin adding the ability to split object selections.

[Kakoune]: https://kakoune.org

[![asciicast](https://asciinema.org/a/239870.svg)](https://asciinema.org/a/239870)

## Installation

Add [`split-object.kak`](rc/split-object.kak) to your autoload or source it manually.

``` kak
require-module split-object
```

## Usage

Select a region and enter split-object mode with `enter-user-mode split-object`.

## Configuration

Add text objects to the <kbd>s</kbd> command:

``` kak
map -docstring 'Split object' global prompt <a-i> '<esc>: enter-user-mode split-object<ret>'
```

## Objects

- <kbd>b</kbd>, <kbd>(</kbd>, <kbd>)</kbd>: Parenthesis block
- <kbd>B</kbd>, <kbd>{</kbd>, <kbd>}</kbd>: Braces block
- <kbd>r</kbd>, <kbd>[</kbd>, <kbd>]</kbd>: Brackets block
- <kbd>a</kbd>, <kbd>&lt;</kbd>, <kbd>&gt;</kbd>: Angle block
- <kbd>Q</kbd>, <kbd>"</kbd>: Double quote string
- <kbd>q</kbd>, <kbd>'</kbd>: Single quote string
- <kbd>g</kbd>, <kbd>`</kbd>: Grave quote string
- <kbd>w</kbd>: Word
- <kbd>Alt</kbd> + <kbd>w</kbd>: WORD
- <kbd>s</kbd>: Sentence
- <kbd>p</kbd>: Paragraph
- <kbd>c</kbd>: Custom object description
