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

USAGE: $(basename ${BASH_SOURCE[0]}) [--read <int:rows>]

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
   found_entries=$1
   [[ ! ${found_entries} =~ ^[0-9]+$ ]] && {
      printf "${rd}◆${rst} Invalid read value "${br}${found_entries}${rst}". "
      printf "Must be int.\n"
   }

   declare -a lines
   readarray raw_lines < "$data_file"

   len=${#raw_lines[@]}
   while [[ ${len} -gt 0 ]] && [[ ${found_entries} -gt 0 ]] ; do
      ((len=$len-1))
      line="${raw_lines[$len]}"

      # Continuation line
      if [[ ${line} =~ ^\ {19}.* ]] ; then
         lines+="${line}"
         continue
      else
         lines+="${line}"
         ((found_entries=$found_entries-1))
      fi
   done

   # God is this an awful approach.
   # Iterates backwards through the text file, adds to the end of an array, then
   # reads backwards through the array... to get forwards output. That's genuine
   # insanity. It's midnight. And this """works""". Time to turn in for tonight,
   # can work on doing it correctly tomorrow.

   mapfile -d $'\n' lines <<< "${lines[@]}"
   len="${#lines[@]}"
   while [[ $len -ge 0 ]] ; do
      printf "${lines[$len]}"
      ((len=$len-1))
   done
}


add_entry () {
   today="$(date '+%Y/%b/%d %H:%M')"
   spacer="$(for i in {1..19} ; do printf ' ' ; done)"

   tmp=$(mktemp --suffix=.txt)
   echo -e "\n#------------------------- LOGFILE --------------------------" >> ${tmp}
   echo "# Write quick notes, in case you need to refer to them in the" >> ${tmp}
   echo "# future. You are already in insert mode. Just start writing." >> ${tmp}
   echo "# Comments, empty lines, and blank newlines will be stripped." >> ${tmp}

   # the `|| exit` allows the user to `:cq` without the script continuing.
   vim -c "norm! ggO" -c 'startinsert' -c 'set wrap tw=61 cc=62' ${tmp} || exit 1

   readarray lines < ${tmp}
   for idx in "${!lines[@]}" ; do
      line="${lines[$idx]}"

      [[ "${line}" == '' ]] && continue
      [[ "${line}" == $'\n' ]] && continue
      [[ "${line}" =~ ^\ *#.* ]] && continue

      if [[ $idx -eq 0 ]] ; then
         printf "${today}  ${line}" >> ${data_file}
         continue
      else
         printf "${spacer}${line//.*\n+$//}" >> ${data_file}
      fi
   done
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
