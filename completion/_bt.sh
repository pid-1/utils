#!/bin/bash
# _bt.sh
# Completion for bt.sh -- wrapper around `bluetoothctl` for mildly
# more ease of use
#
# Uses some paramater expansion:
#  https://wiki.bash-hackers.org/syntax/pe#use_a_default_value
#  https://wiki.bash-hackers.org/syntax/pe#substring_removal
#
#                                   THINKIES
#-------------------------------------------------------------------------------
#COMP_WORDBREAKS=${COMP_WORDBREAKS[*]/\:/}
# Not a great solution. Seems to be no way to only make this persist for the
# duration of the completion. It's all or nothing. Yucky.
#
# Could also use the `-o filenames` complete option, and give the user the
# option to either escape colons, or begin the ID with a "'" so it'll treat
# everything as a Bash "word".
#
# Struggling to make the CLI completion work with colon-separated values. Wonder
# if I just s,:,/,g to make parsing easier?
#_DEVICES+=("${id//:/\/} ${name}")
# This works, but I don't think it's ideal. Unless I can get some color-coded
# completion to make it a bit more clear which values have not yet been typed.
# This could actually be a really solid method.
#
# Okay. did much research. `complete` will only output _raw_ text. It is not
# possible to manually add color escapes. Odd limitation. Especailly when <tab>
# completion for `ls` can add color, for example. As can...
#
#bind 'set colored-stats on'
# This sorta works. The problem is, if you're using a "grep" search, the match
# isn't necessarily at the beginning of the string. However, `colored-stats`
# will always display the length of the characters in the CWORD, from the start
# of the string, in a color. But they should be displaying the characters that
# are common, rather than just that number from the start. Bah.
#
#set completion-prefix-display-length 2
# Slightly better than the previous option, as we can define a minimum number
# of characters to be entered before matching starts. Cuts down on the amount
# of times it'll fail. But it still will.
#
# Turns out the more I've worked on this project, the more I've realized I'm
# just making a completion script for bluetoothctl, not 
#
# Yup, the whole process of making this was pointless. Unlike `dr`, my
# wrapper around `docker` commands, this doesn't really serve any purpose.
# Turns out tab completion was sufficient to cover all my use cases. 


_BT_COMP_CONNECT ()
{
   declare -a _DEVICES

   while read -r _ id name ; do
      _DEVICES+=("${id//:/.}  ${name}")
   done < <(bluetoothctl devices)

   local IFS=$'\n'

   local _OPTS=( $(compgen -W "${_DEVICES[*]}" | grep -iF "${COMP_WORDS[$COMP_CWORD]}") )

   [[ "${#_OPTS[@]}" -eq 1 ]] && {
      _OPT="${_OPTS[@]%% *}" 
      COMPREPLY=( "${_OPT//./:}" )
   } || {
      for _RES in "${_OPTS[@]}" ; do
         COMPREPLY+=( "$( printf '%-*s' $(tput cols) "$_RES")" )
      done;
   }
}


_BT_COMP_MAIN () {
   local cur="${COMP_WORDS[$COMP_CWORD]}"
   local prev="${COMP_WORDS[$COMP_CWORD - 1]}"

   local opts=(
         'alias'
         'devices'
         'paired-devices'
         'power'
         'connect'
         'disconnect'
   )

   [[ ${COMP_CWORD} == 1 ]] && {
      COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
   } || {
      case "${prev}" in
         'alias'|'devices'|'paired-devices'|'disconnect')
            return
            ;;
         'power')
            COMPREPLY=($(compgen -W 'on off' -- "$cur"))
            ;;
         'connect')
            _BT_COMP_CONNECT
            ;;
      esac
   }
}

#_BT_COMP_MAIN
complete -F _BT_COMP_MAIN bt
