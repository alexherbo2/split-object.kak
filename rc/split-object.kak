declare-option -hidden str-list split_object_selections
declare-option -hidden str-list split_object_openers

declare-user-mode split-object

define-command -hidden split-object -params 3 %{
  unset-option window split_object_selections
  evaluate-commands -no-hooks -draft -itersel -save-regs '/' %{ try %{
    set-register / "\Q%arg(2)\E|\Q%arg(3)\E"
    # Abort if nothing to select
    try %{
      execute-keys 's<ret>'
    } catch %{
      fail 'Nothing selected'
    }
    # Rotate to set the index of the main selection to 1
    execute-keys ')'
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
    # Execute the object command
    execute-keys "l<a-i>%arg(1)"
    evaluate-commands set-option -add window split_object_selections %val(selections_desc)
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
      split-object "c%val(text)<ret>" "\E%reg(O)\Q" "\E%reg(C)\Q"
    }
  } -on-abort %{
    info # clear
  }
}

map global split-object b ': split-object b ( )<ret>' -docstring 'Parenthesis block'
map global split-object ( ': split-object b ( )<ret>' -docstring 'Parenthesis block'
map global split-object ) ': split-object b ( )<ret>' -docstring 'Parenthesis block'

map global split-object B ': split-object B { }<ret>' -docstring 'Braces block'
map global split-object { ': split-object B { }<ret>' -docstring 'Braces block'
map global split-object } ': split-object B { }<ret>' -docstring 'Braces block'

map global split-object r ': split-object r [ ]<ret>' -docstring 'Brackets block'
map global split-object [ ': split-object r [ ]<ret>' -docstring 'Brackets block'
map global split-object ] ': split-object r [ ]<ret>' -docstring 'Brackets block'

map global split-object a ': split-object a <lt> <gt><ret>' -docstring 'Angle block'
map global split-object <lt> ': split-object a <lt> <gt><ret>' -docstring 'Angle block'
map global split-object <gt> ': split-object a <lt> <gt><ret>' -docstring 'Angle block'

map global split-object Q ': split-object Q %(") %(")<ret>' -docstring 'Double quote string'
map global split-object '"' ': split-object Q %(") %(")<ret>' -docstring 'Double quote string'

map global split-object q ': split-object q %('') %('')<ret>' -docstring 'Single quote string'
map global split-object "'" ': split-object q %('') %('')<ret>' -docstring 'Single quote string'

map global split-object g ': split-object g ` `<ret>' -docstring 'Grave quote string'
map global split-object ` ': split-object g ` `<ret>' -docstring 'Grave quote string'

map global split-object c ': split-object-custom<ret>' -docstring 'Custom object description'
