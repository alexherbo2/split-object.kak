declare-option -hidden str-list split_object_selections
declare-option -hidden str split_object_close

declare-user-mode split-object

define-command -hidden split-object -params 2 %{
  unset-option window split_object_selections
  evaluate-commands -no-hooks -draft -itersel -save-regs '/P' %{ try %{
    # Save parent selection
    set-register P %val(selection_desc)
    set-register / %arg(2)
    # Abort if nothing to select
    try %{
      execute-keys 's<ret>'
    } catch %{
      fail 'Nothing selected'
    }
    # Rotate to set the index of the main selection to 1
    execute-keys ')'
    # Execute the object command
    # Discard selections expanding
    evaluate-commands -itersel -draft %{
	  try %{
        evaluate-commands %sh{
          if [ "$kak_opt_split_object_close" ]; then
            if [ "$kak_selection_desc" == "$kak_opt_split_object_close" ]; then
              printf 'set-option window split_object_close ""\n'
            fi
            exit
          fi
          printf 'execute-keys "<a-i>%s"\n' '%arg(1)'
          printf 'fail "trigger next step"'
        }
	  } catch %{
        evaluate-commands %sh{
          # Parent selection
          parent_anchor=${kak_main_reg_P%,*}
          parent_anchor_line=${parent_anchor%.*}
          parent_anchor_column=${parent_anchor#*.}
          parent_cursor=${kak_main_reg_P#*,}
          parent_cursor_line=${parent_cursor%.*}
          parent_cursor_column=${parent_cursor#*.}
          anchor=${kak_selection_desc%,*}
          anchor_line=${anchor%.*}
          anchor_column=${anchor#*.}
          cursor=${kak_selection_desc#*,}
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
          printf 'set-option -add window split_object_selections %s\n' "$kak_selection_desc"
          [ "$1" == 's' ] || [ "$1" == 'p' ] || [ "$1" == 'w' ] || [ "$1" == '<lt>a-w<gt>' ] && exit
          printf 'exec ";/<ret>"\nset-option window split_object_close %s\n' "%val{selection_desc}"
        }
      }
	}  }}
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
      split-object "c%val(text)<ret>" "%reg(O)|%reg(C)"
    }
  } -on-abort %{
    info # clear
  }
}

map global split-object b ': split-object b [()]<ret>' -docstring 'Parenthesis block'
map global split-object ( ': split-object b [()]<ret>' -docstring 'Parenthesis block'
map global split-object ) ': split-object b [()]<ret>' -docstring 'Parenthesis block'

map global split-object B ': split-object B [{}]<ret>' -docstring 'Braces block'
map global split-object { ': split-object B [{}]<ret>' -docstring 'Braces block'
map global split-object } ': split-object B [{}]<ret>' -docstring 'Braces block'

map global split-object r ': split-object r [\[\]]<ret>' -docstring 'Brackets block'
map global split-object [ ': split-object r [\[\]]<ret>' -docstring 'Brackets block'
map global split-object ] ': split-object r [\[\]]<ret>' -docstring 'Brackets block'

map global split-object a ': split-object a [<lt><gt>]<ret>' -docstring 'Angle block'
map global split-object <lt> ': split-object a [<lt><gt>]<ret>' -docstring 'Angle block'
map global split-object <gt> ': split-object a [<lt><gt>]<ret>' -docstring 'Angle block'

map global split-object Q ': split-object Q %(")<ret>' -docstring 'Double quote string'
map global split-object '"' ': split-object Q %(")<ret>' -docstring 'Double quote string'

map global split-object q ': split-object q %('')<ret>' -docstring 'Single quote string'
map global split-object "'" ': split-object q %('')<ret>' -docstring 'Single quote string'

map global split-object g ': split-object g `<ret>' -docstring 'Grave quote string'
map global split-object ` ': split-object g `<ret>' -docstring 'Grave quote string'

map global split-object w ': split-object w \w+<ret>' -docstring 'Word'
map global split-object <a-w> ': split-object <lt>a-w<gt> \w+<ret>' -docstring 'Big word'

map global split-object s ': split-object s [^\n]+<ret>' -docstring 'Sentence'
map global split-object p ': split-object p [^\n]+<ret>' -docstring 'Paragraph'

map global split-object c ': split-object-custom<ret>' -docstring 'Custom object description'
