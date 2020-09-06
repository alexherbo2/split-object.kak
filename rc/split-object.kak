provide-module split-object %{

  # Options ────────────────────────────────────────────────────────────────────

  declare-option -hidden str-list split_object_selections
  declare-option -hidden str-list split_object_opening_pairs_selections

  # Modes ──────────────────────────────────────────────────────────────────────

  declare-user-mode split-object

  # Mappings ───────────────────────────────────────────────────────────────────

  map -docstring 'Parenthesis block' global split-object b ': split-object-balanced b [()]<ret>'
  map -docstring 'Parenthesis block' global split-object ( ': split-object-balanced b [()]<ret>'
  map -docstring 'Parenthesis block' global split-object ) ': split-object-balanced b [()]<ret>'

  map -docstring 'Braces block' global split-object B ': split-object-balanced B [{}]<ret>'
  map -docstring 'Braces block' global split-object { ': split-object-balanced B [{}]<ret>'
  map -docstring 'Braces block' global split-object } ': split-object-balanced B [{}]<ret>'

  map -docstring 'Brackets block' global split-object r ': split-object-balanced r [\[\]]<ret>'
  map -docstring 'Brackets block' global split-object [ ': split-object-balanced r [\[\]]<ret>'
  map -docstring 'Brackets block' global split-object ] ': split-object-balanced r [\[\]]<ret>'

  map -docstring 'Angle block' global split-object a ': split-object-balanced a [<lt><gt>]<ret>'
  map -docstring 'Angle block' global split-object <lt> ': split-object-balanced a [<lt><gt>]<ret>'
  map -docstring 'Angle block' global split-object <gt> ': split-object-balanced a [<lt><gt>]<ret>'

  map -docstring 'Double quote string' global split-object Q ': split-object-balanced Q %(")<ret>'
  map -docstring 'Double quote string' global split-object '"' ': split-object-balanced Q %(")<ret>'

  map -docstring 'Single quote string' global split-object q ': split-object-balanced q %('')<ret>'
  map -docstring 'Single quote string' global split-object "'" ': split-object-balanced q %('')<ret>'

  map -docstring 'Grave quote string' global split-object g ': split-object-balanced g `<ret>'
  map -docstring 'Grave quote string' global split-object ` ': split-object-balanced g `<ret>'

  map -docstring 'Word' global split-object w ': split-object w \w+<ret>'
  map -docstring 'WORD' global split-object <a-w> ': split-object <lt>a-w<gt> \w+<ret>'

  map -docstring 'Sentence' global split-object s ': split-object s [^\n]+<ret>'
  map -docstring 'Paragraph' global split-object p ': split-object p [^\n]+<ret>'

  map -docstring 'Custom object description' global split-object c ': split-object-prompt<ret>'

  # Commands ───────────────────────────────────────────────────────────────────

  define-command -hidden split-object -params 2 %{
    split-object-implementation %arg{1} %arg{2} ''
  }

  define-command -hidden split-object-balanced -params 2 %{
    split-object-implementation %arg{1} %arg{2} split-object-select-opening-pairs-and-position-cursor
  }

  define-command -hidden split-object-prompt %{
    info -title 'Enter object description' 'Format: <open-regex>,<close-regex>'
    prompt split-object: %{
      evaluate-commands -save-regs 'oc' %{
        set-register o %sh(printf '%s' "${kak_text%,*}")
        set-register c %sh(printf '%s' "${kak_text#*,}")
        split-object-balanced "c%val{text}<ret>" "%reg{o}|%reg{c}"
      }
    }
    # Clear info when leaving prompt
    hook -once window ModeChange 'pop:prompt:.*' info
  }

  define-command -hidden split-object-implementation -params 3 %{
    unset-option window split_object_selections
    # Iterate each selection
    evaluate-commands -draft -itersel -save-regs '/p' %{
      # Save parent selection
      set-register p %val{selection_desc}
      set-register / %arg{2}
      # Abort if nothing selected
      try %{
        execute-keys 's<ret>'
      } catch %{
        fail 'Nothing selected'
      }
      # Rotate to set the index of the main selection to 1.
      execute-keys ')'
      # Position the cursor
      execute-keys '<a-:>'
      # Switch for balanced objects
      evaluate-commands %arg{3}
      # Select inner surrounding object
      execute-keys '<a-i>' %arg{1}
      # Discard selections expanding
      evaluate-commands %sh{
        # Parent selection
        # <anchor-line>.<anchor-column>,<cursor-line>.<cursor-column>
        parent_anchor=${kak_main_reg_p%,*}
        parent_anchor_line=${parent_anchor%.*}
        parent_anchor_column=${parent_anchor#*.}
        parent_cursor=${kak_main_reg_p#*,}
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
    }
    # Apply selections
    try %{
      select %opt{split_object_selections}
    } catch %{
      fail 'Nothing selected'
    }
  }

  define-command -hidden split-object-select-opening-pairs-and-position-cursor %{
    unset-option window split_object_opening_pairs_selections
    evaluate-commands %sh{
      eval "set -- $kak_selections_desc"
      # Abort if unbalanced selections
      if test $(($# % 2)) -ne 0; then
        printf 'fail Unbalanced selections\n'
      fi
      # Select opening pairs
      while test $# -ge 2; do
        opening=$1 closing=$2
        shift 2
        printf 'set-option -add window split_object_opening_pairs_selections %s\n' "$opening"
      done
    }
    # Select opening pairs
    select %opt{split_object_opening_pairs_selections}
    # Position the cursor for the object command
    execute-keys 'l'
  }
}
