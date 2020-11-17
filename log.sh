#!/bin/bash
# New version of a my quick notetaking utility.
# If I'm about to install software, uninstall software, make changes to
# a config file, and want a place to jot down what I've done. The
# previous version has been _invaluable_ to recall a change I've made
# two weeks ago at 2am.
#
# It is important to have the text in a plaintext file, so output can be
# parsed on the commandline if necessary. As well as using operations
# like grep to quickly search.
#
# This is going to be an insane thing to say, but it may actually be
# easier to NOT need to open an editor. Even if that editor is the
# majestic and wonderful spaceship vim. `mapfile -u 1` is pretty
# effective, though you can't use any movement commands. Only typing and
# backspace. So that's kinda dumb.

rst="\033[0m"     # Reset
gr="\033[32m"     # Green
rd="\033[31m"     # Red
yl="\033[33m"     # Yellow
bk="\033[30m"     # Black (dim)
br="\033[37;1m"   # White (bright)


config_path="${HOME}/.config/hre-utils"
data_file="${config_path}/logfile.txt"

usage () {
cat << EOF

USAGE: $(basename ${BASH_SOURCE[0]}) [--read <rows>]

Run the utility. It opens 'vim' in insert mode. Type an entry to save to the
logfile. Some minor processing is done before saving the line:
   1. Newlines and lines beginning with a comment character (#) are stripped
   2. Subsequent lines are intented +19 to properly justify beneath the date

The data file should be easily human readable, and able to parse with common
CLI tools (grep, sed).

EOF
exit $?
}


setup () {
   [[ ! -d "${config_path}" ]] && {
      printf "${br}◆${rst} ${config_path} not found -- creating"
   }

   [[ ! $(which vim 2>/dev/null) ]] && {
      printf "${rd}◆${rst} vim not found in \$PATH. Fuck you.\n"
      exit 1
   }
}


read_entries () {
   num_entries=$1
   [[ ! ${num_entries} =~ ^[0-9]+$ ]] && {
      printf "${rd}◆${rst} Invalid read value: ${br}${num_entries}${rst}. "
      printf "Must be int.\n"
   }

   declare -a lines
   readarray raw_lines < "$data_file"


   len=${#raw_lines[@]}
   while [[ ${len} -ge 1 ]] && [[ ${num_entries} -ge 0 ]] ; do
      len=$((${len}-1))
      line="${raw_lines[$len]}"

      echo -e "Line ($len): "${line}""

      ## Toss out blank lines, or empty newlines
      #[[ ${line} == '' ]] && continue
      #[[ ${line} =~ \n ]] && continue

      ## Continuation line
      #[[ ${line} =~ '^[ ]{19}.*$' ]] && {
      #   lines+=${line}
      #   continue
      #}

      #lines+=${line}
      #len=$((${len}-1))
      #num_entries=$((${num_entries}-1))
   done

   #echo "${lines[@]}"
}


add_entry () {
   today="$(date '+%Y/%b/%d %H:%M')"
}


setup

case "$1" in
   -h|--help|help)
      usage 0
      ;;
   -r|--read|read)
      shift
      read_entries "$1"
      ;;
   -a|--add|add)
      shift
      #quick_entry "$1"
      printf "${yl}◆${rst} NYI\n"
      exit 1
      ;;
   '')
      add_entry
      ;;
   *)
      usage 1
   ;;
esac
