declare-option -hidden str-list split_object_selections
declare-option -hidden str-list split_object_openers

declare-user-mode split-object

define-command -hidden split-object -params 2 %{
  split-object-implementation nop %arg(1) %arg(2)
}

define-command -hidden split-object-balanced -params 2 %{
  split-object-implementation fail %arg(1) %arg(2)
}

define-command -hidden split-object-implementation -params 3 %{
  unset-option window split_object_selections
  evaluate-commands -no-hooks -draft -itersel -save-regs '/P' %{ try %{
    # Save parent selection
    set-register P %val(selection_desc)
    set-register / %arg(3)
    # Abort if nothing to select
    try %{
      execute-keys 's<ret>'
    } catch %{
      fail 'Nothing selected'
    }
    # Rotate to set the index of the main selection to 1
    execute-keys ')'
    # Switch for balanced objects
    # 'nop' → non balanced objects
    # 'fail' → balanced objects
    try %{
      evaluate-commands %arg(1)
    } catch %{
      unset-option window split_object_openers
      evaluate-commands %sh{
        eval "set -- $kak_selections_desc"
        # Abort if unbalanced selections
        if test $(($# % 2)) -ne 0; then
          printf 'fail Unbalanced selections\n'
        fi
        # Select openers and skip closers
        while test $# -ge 2; do
          printf 'set-option -add window split_object_openers %s\n' "$1"
          shift 2
        done
      }
      # Select openers
      select %opt(split_object_openers)
      # Position the cursor
      execute-keys 'l'
    }
    # Execute the object command
    execute-keys "<a-i>%arg(2)"
    # Discard selections expanding
    evaluate-commands %sh{
      # Parent selection
      parent_anchor=${kak_main_reg_P%,*}
      parent_anchor_line=${parent_anchor%.*}
      parent_anchor_column=${parent_anchor#*.}
      parent_cursor=${kak_main_reg_P#*,}
      parent_cursor_line=${parent_cursor%.*}
      parent_cursor_column=${parent_cursor#*.}
      eval "set -- $kak_selections_desc"
      for selection do
        anchor=${selection%,*}
        anchor_line=${anchor%.*}
        anchor_column=${anchor#*.}
        cursor=${selection#*,}
        cursor_line=${cursor%.*}
        cursor_column=${cursor#*.}
        if test "$anchor_line" -lt "$parent_anchor_line"; then
          exit
        elif test "$anchor_line" -eq "$parent_anchor_line" -a "$anchor_column" -lt "$parent_anchor_column"; then
          exit
        elif test "$cursor_line" -gt "$parent_cursor_line"; then
          exit
        elif test "$cursor_line" -eq "$parent_cursor_line" -a "$cursor_column" -gt "$parent_cursor_column"; then
          exit
        fi
        printf 'set-option -add window split_object_selections %s\n' "$selection"
      done
    }
  }}
  try %{
    select %opt(split_object_selections)
  } catch %{
    fail 'Nothing selected'
  }
}

define-command -hidden split-object-custom %{
  info -title 'Enter object description' 'Format: <open-regex>,<close-regex> (escape commas with ''\'')'
  prompt 'Object description:' %{
    info # clear
    evaluate-commands -save-regs 'CO' %{
      set-register O %sh(printf '%s' "${kak_text%,*}")
      set-register C %sh(printf '%s' "${kak_text#*,}")
      split-object-balanced "c%val(text)<ret>" "%reg(O)|%reg(C)"
    }
  } -on-abort %{
    info # clear
  }
}

map global split-object b ': split-object-balanced b [()]<ret>' -docstring 'Parenthesis block'
map global split-object ( ': split-object-balanced b [()]<ret>' -docstring 'Parenthesis block'
map global split-object ) ': split-object-balanced b [()]<ret>' -docstring 'Parenthesis block'

map global split-object B ': split-object-balanced B [{}]<ret>' -docstring 'Braces block'
map global split-object { ': split-object-balanced B [{}]<ret>' -docstring 'Braces block'
map global split-object } ': split-object-balanced B [{}]<ret>' -docstring 'Braces block'

map global split-object r ': split-object-balanced r [\[\]]<ret>' -docstring 'Brackets block'
map global split-object [ ': split-object-balanced r [\[\]]<ret>' -docstring 'Brackets block'
map global split-object ] ': split-object-balanced r [\[\]]<ret>' -docstring 'Brackets block'

map global split-object a ': split-object-balanced a [<lt><gt>]<ret>' -docstring 'Angle block'
map global split-object <lt> ': split-object-balanced a [<lt><gt>]<ret>' -docstring 'Angle block'
map global split-object <gt> ': split-object-balanced a [<lt><gt>]<ret>' -docstring 'Angle block'

map global split-object Q ': split-object-balanced Q %(")<ret>' -docstring 'Double quote string'
map global split-object '"' ': split-object-balanced Q %(")<ret>' -docstring 'Double quote string'

map global split-object q ': split-object-balanced q %('')<ret>' -docstring 'Single quote string'
map global split-object "'" ': split-object-balanced q %('')<ret>' -docstring 'Single quote string'

map global split-object g ': split-object-balanced g `<ret>' -docstring 'Grave quote string'
map global split-object ` ': split-object-balanced g `<ret>' -docstring 'Grave quote string'

map global split-object w ': split-object w \w+<ret>' -docstring 'Word'
map global split-object <a-w> ': split-object <lt>a-w<gt> \w+<ret>' -docstring 'Big word'

map global split-object s ': split-object s [^\n]+<ret>' -docstring 'Sentence'
map global split-object p ': split-object p [^\n]+<ret>' -docstring 'Paragraph'

map global split-object c ': split-object-custom<ret>' -docstring 'Custom object description'
