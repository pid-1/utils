#!/bin/bash
# _conf.sh
#
# Completion script for `conf`
# Currently hard-codes the value for the data file. Should maybe want to make
# dynamic in the future.

#                                  functions
#-------------------------------------------------------------------------------
function _conf_completion ()
{
   [[ "${#COMP_WORDS[@]}" -ne 2 ]] && return

   COMPREPLY=( $(compgen -W "${_FILES[@]}" -- "${COMP_WORDS[1]}") )
}

#                                  load data
#-------------------------------------------------------------------------------
# Loads names of files into an array
declare -a _FILES=$(python -c "
import json
with open('$HOME/.config/hre-utils/dotfiles.json') as f:
   try:
      files = json.load(f)['Files'].keys()
      print('\\n'.join(files))
   except:
      pass
")

#                                  complete
#-------------------------------------------------------------------------------
complete -F _conf_completion conf
