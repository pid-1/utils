#!/bin/bash
# _bt.sh
# Completion for a couple of bluetoothctl's commands.
# Adds slightly better ease of use.
#
# Uses some paramater expansion:
#  https://wiki.bash-hackers.org/syntax/pe#use_a_default_value
#  https://wiki.bash-hackers.org/syntax/pe#substring_removal

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

complete -F _BT_COMP_MAIN bt
