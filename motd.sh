#!/bin/bash
# MOTD w/ bash, awk, sed
#
# Paired with the 'update_motd.sh` script to pipe the output
# from this script -> /etc/motd
#
# Arch Linux automatically reads /etc/motd on login

WIDTH=80

#interface=
# The below loop will set $interface to the first found interface that is "UP".
# Comment it out to set manually above.
while IFS=$'\n' read line ; do
	interface=$( echo -e "$line" | awk '$2 == "UP" { print $1}' )
	[[ $interface ]] && break
done < <(ip -br link)

# ANSI escape colors
Custom ()
{
   echo -e "\033[38;5;${1}m"
}
Black="\033[30m"   ;  brBlack="\033[30;1m"
Red="\033[31m"     ;  brRed="\033[31;1m"
Green="\033[32m"   ;  brGreen="\033[32;1m"
Yellow="\033[33m"  ;  brYellow="\033[33;1m"
Blue="\033[34m"    ;  brBlue="\033[34;1m"
Magenta="\033[35m" ;  brMagenta="\033[35;1m"
Cyan="\033[36m"    ;  brCyan="\033[36;1m"
White="\033[37m"   ;  brWhite="\033[37;1m"

Reset="\033[0m"

# If we're in the console:
if [[ "$TERM" == "linux" ]] || [[ "$1" == 'linux' ]] ; then
   FG="${brRed}"
   BG="${brBlack}"
   TEXT="${White}"
   ACCENT="${brYellow}"
   GOOD="${brGreen}"
   WARN="${brYellow}"
   CRIT="${brRed}"
else
   FG="${Red}"
   BG="${Black}"
   TEXT="${Cyan}"
   ACCENT="${Yellow}"
   GOOD="${Green}"
   WARN="${Yellow}"
   CRIT="${Red}"
fi

#==============================================================================
#                              senatus populusque
#------------------------------------------------------------------------------
declare -a HEADER_01=(
   "┌─┐┌─┐┌┐┌┌─┐┌┬┐┬ ┬┌─┐  ┌─┐┌─┐┌─┐┬ ┬┬  ┬ ┬┌─┐┌─┐ ┬ ┬┌─┐"
   "└─┐├┤ │││├─┤ │ │ │└─┐  ├─┘│ │├─┘│ ││  │ │└─┐│─┼┐│ │├┤ "
   "└─┘└─┘┘└┘┴ ┴ ┴ └─┘└─┘  ┴  └─┘┴  └─┘┴─┘└─┘└─┘└─┘└└─┘└─┘")

length_HEADER_O1=$( wc -m <<< "$HEADER_01" )
offset_HEADER_01=$( bc <<< "(${WIDTH} - $length_HEADER_O1) / 2" )

for line in "${HEADER_01[@]}" ; do
   line="${FG}${line}${Reset}"
   printf "%${offset_HEADER_01}s${line}\n"
done


#==============================================================================
#                                R O M A N U S
#------------------------------------------------------------------------------
declare -a HEADER_02=(
   "██████╗  ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗██╗   ██╗███████╗"
   "██╔══██╗██╔═══██╗████╗ ████║██╔══██╗████╗  ██║██║   ██║██╔════╝"
   "██████╔╝██║   ██║██╔████╔██║███████║██╔██╗ ██║██║   ██║███████╗"
   "██╔══██╗██║   ██║██║╚██╔╝██║██╔══██║██║╚██╗██║██║   ██║╚════██║"
   "██║  ██║╚██████╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║╚██████╔╝███████║"
   "╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝")

length_HEADER_O2=$( wc -m <<<  "$HEADER_02" )
offset_HEADER_02=$( bc <<< "(${WIDTH} - $length_HEADER_O2) / 2" )

# Gotta use triple escape'd '\' for `sed`:  black="\\\033[30m", or "\\${Black}"
for line in "${HEADER_02[@]}" ; do
   fline=$( sed -r "s/█/\\${FG}█\\${Reset}/g" <<< "$line" )
   fline=$( sed -r "s/([╗═╔╚║╝])/\\${BG}\1\\${Reset}/g" <<< "$fline" )
   printf "%${offset_HEADER_02}s${fline}\n"
done

#==============================================================================
#                                    STATS
#------------------------------------------------------------------------------
#-----| IP ADDR |-----#
_IP_ADDR=$( ip -f inet -4 -br address | grep $interface | awk '{print $3}' )

_SEARCH="([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(\.[0-9]{1,3})(/[0-9]{1,2})"
_REPLACE="`printf "${TEXT}"`\\1`printf "${ACCENT}"`\2`printf "${Reset}"``printf "${TEXT}"`\\3`printf "${Reset}"`"
_IP_ADDR=$( sed -E "s:${_SEARCH}:${_REPLACE}:g" <<< "$_IP_ADDR" )
# Kinda a stupid way of going about this.
# `sed` doesn't play nicely with '\e' or \033', only '\x1b'.

#-----| RAM/CPU |-----#
_RAM_FREE=$(free -mh | awk 'NR==2 { print $3 "/" $2 }')
_CPU_FREE=$(top -n 1 | awk 'NR==3 { print $2 }' )

#-----| Temperature |-----#
_TEMP=$(sensors | grep -i -C1 "isa adapter")

_TEMP_PRETTY=$( awk 'NR==3 { print $4 }' <<< "$_TEMP" )
_TEMP_CURRENT=$( awk 'NR==3 { print $4 }' <<< "$_TEMP" | sed 's/[^0-9\.]//g')
_TEMP_HIGH=$( awk 'NR==3 { print $7 }' <<< "$_TEMP" | sed 's/[^0-9\.]//g')
_TEMP_CRIT=$( awk 'NR==3 { print $10 }' <<< "$_TEMP" | sed 's/[^0-9\.]//g')

_IS_TEMP_GOOD=$(
   awk "BEGIN { print (${_TEMP_CURRENT} < ${_TEMP_HIGH} ? \"True\" : \"\")}"
)
_IS_TEMP_HIGH=$(
   awk "BEGIN { print (${_TEMP_CURRENT} >= ${_TEMP_HIGH} && ${_TEMP_CURRENT} < ${_TEMP_CRIT} ? \"True\" : \"\")}"
)
_IS_TEMP_CRIT=$(
   awk "BEGIN { print (${_TEMP_CURRENT} >= ${_TEMP_CRIT} ? \"True\" : \"\")}"
)

[[ $_IS_TEMP_GOOD ]] && _TEMP_COLOR="${GOOD}"
[[ $_IS_TEMP_HIGH ]] && _TEMP_COLOR="${WARN}"
[[ $_IS_TEMP_CRIT ]] && _TEMP_COLOR="${CRIT}"

#-----| Uptime |-----#
# Dropping this version of `uptime`. I can't find a good reference for all the
# possible output from uptime. Every couple days I find a new way it outputs
# time. Switching to `uptime -p`. Easier to parse.
#_UPTIME=$( uptime | sed -E 's/.*up ([0-9]* (days?|min)\, )?[ ]?\,?[ ]*([0-9]+:[0-9]+)?.*/\1\3/g' )
#_UPTIME=$( awk '{print $2 " " $3}' < <(uptime -p) | sed 's/\,//g' )
#
# Nvm, with a bit of help got a `sed` command that works:
_UPTIME=$( sed -E 's/^ *([0-9:]+) *up *(.*)\, *([0-9]+) users?\, *load averages?: (.*)$/\2/g' < <(uptime) )

#==============================================================================
#                                Format & Print
#------------------------------------------------------------------------------
_BIG_SPACER='──────────────────────────────────────────────────'
_BIG_SPACER_length=$( wc -m <<< $_BIG_SPACER )
_BIG_SPACER_offset=$( bc <<< "($WIDTH - $_BIG_SPACER_length) / 2" )

_SMALL_SPACER='───────────────────────────'
_SMALL_SPACER_length=$( wc -m <<< $_SMALL_SPACER )
_SMALL_SPACER_offset=$( bc <<<  "($WIDTH - $_SMALL_SPACER_length) / 2" )

# To correctly format, use the following offset formula:
# >>> midpoint = WIDTH / 2
# >>> offset = midpoint - (len(word) + 3)
#
# In this case, we're printing for an 80column terminal, so midpoint is at 40
# For example:
# >>> word = "Welcome", length 7
# >>> offset = 40 - (7 + 3) = 30

printf "%${_BIG_SPACER_offset}s${BG}${_BIG_SPACER}${Reset}\n"
printf "%30sWelcome  :  ${FG}${USER}${Reset}\n"
printf "%${_SMALL_SPACER_offset}s${BG}${_SMALL_SPACER}${Reset}\n"
printf "%31sUptime     ${ACCENT}${_UPTIME}${Reset}\n"
printf "%30sIP Addr     ${_IP_ADDR}\n"
printf "%34sSys     ${TEXT}${_CPU_FREE}%% ${_TEMP_COLOR}${_TEMP_PRETTY} ${BG}CPU${Reset}\n"
printf "%37s     ${TEXT}${_RAM_FREE} ${BG}RAM${Reset}\n"
printf "%${_BIG_SPACER_offset}s${BG}${_BIG_SPACER}${Reset}\n"
