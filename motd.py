#!/usr/bin/env python3
# Using: http://patorjk.com/software/taag
#
# Paired with the 'update_motd.sh` script to pipe the output
# from this script -> /etc/motd
#
# Arch Linux automatically reads /etc/motd on boot

import re, os, sys
from datetime   import timedelta
from subprocess import check_output

WIDTH = 80
CENTER = round(WIDTH / 2)

class Colors:
   # ANSI escape colors
   Black    = '\u001b[30m'  ;  brBlack     = '\u001b[30;1m'
   Red      = '\u001b[31m'  ;  brRed       = '\u001b[31;1m'
   Green    = '\u001b[32m'  ;  brGreen     = '\u001b[32;1m'
   Yellow   = '\u001b[33m'  ;  brYellow    = '\u001b[33;1m'
   Blue     = '\u001b[34m'  ;  brBlue      = '\u001b[34;1m'
   Magenta  = '\u001b[35m'  ;  brMagenta   = '\u001b[35;1m'
   Cyan     = '\u001b[36m'  ;  brCyan      = '\u001b[36;1m'
   White    = '\u001b[37m'  ;  brWhite     = '\u001b[37;1m'

   Reset = '\u001b[0m'

   # 256 colors in the form of: \u001b[38;5;{color_number}m
   c = lambda x: f'\u001b[38;5;{x}m'

   CONSOLE_MODE = bool(len(sys.argv) > 1
                   and sys.argv[-1] == 'linux'
                    or os.environ.get('TERM') == 'linux')

   if CONSOLE_MODE:
      FG     = brRed
      BG     = brBlack
      TEXT   = White
      ACCENT = brYellow
      GOOD   = brGreen
      WARN   = brYellow
      CRIT   = brRed
   else:
      FG     = Red
      BG     = Black
      TEXT   = Cyan
      ACCENT = Yellow
      GOOD   = Green
      WARN   = Yellow
      CRIT   = Red

#==============================================================================
#                              senatus populusque
#------------------------------------------------------------------------------
header_prefix = [
   "┌─┐┌─┐┌┐┌┌─┐┌┬┐┬ ┬┌─┐  ┌─┐┌─┐┌─┐┬ ┬┬  ┬ ┬┌─┐┌─┐ ┬ ┬┌─┐",
   "└─┐├┤ │││├─┤ │ │ │└─┐  ├─┘│ │├─┘│ ││  │ │└─┐│─┼┐│ │├┤ ",
   "└─┘└─┘┘└┘┴ ┴ ┴ └─┘└─┘  ┴  └─┘┴  └─┘┴─┘└─┘└─┘└─┘└└─┘└─┘"]

for line in header_prefix:
   print(f'{Colors.FG}{line:^{WIDTH}}{Colors.Reset}')

#==============================================================================
#                                R O M A N U S
#------------------------------------------------------------------------------
header_main = [
   "██████╗  ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗██╗   ██╗███████╗",
   "██╔══██╗██╔═══██╗████╗ ████║██╔══██╗████╗  ██║██║   ██║██╔════╝",
   "██████╔╝██║   ██║██╔████╔██║███████║██╔██╗ ██║██║   ██║███████╗",
   "██╔══██╗██║   ██║██║╚██╔╝██║██╔══██║██║╚██╗██║██║   ██║╚════██║",
   "██║  ██║╚██████╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║╚██████╔╝███████║",
   "╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝"]

# For some reason it isn't working to do a:
# >>> print(f'{line:^{WIDTH}}')
# Possibly because the line is actually about four-hundred characters long of
# mostly ANSI color escapes. This is a little hacky, but it works.
header_main_length = round(len(header_main[0]))
width_difference = WIDTH - header_main_length
compensate = round(width_difference / 2)

for line in header_main:
   line = re.sub('█', f'{Colors.FG}█{Colors.Reset}', line)
   line = re.sub(r'([╗═╔╚║╝])', f'{Colors.BG}\\1{Colors.Reset}', line)
   print(f'{" " * compensate}{line}')

#==============================================================================
#                                    STATS
#------------------------------------------------------------------------------
#-----| User |-----#
user = os.environ.get('USER')

#-----| IP addr |-----#
ip_addr = None
_ip_addr = check_output(['ip', '-f', 'inet', '-4', '-br', 'address']).decode()
for addr in _ip_addr.split('\n'):
   if 'enp' in addr:
      ip_addr = addr.split()[2]

      address = re.compile(r'([\d]{1,3}\.[\d]{1,3}\.[\d]{1,3})(\.[\d]{1,3})(/[\d]{1,2})')
      ip_addr = re.sub(address, f'{Colors.TEXT}\\1{Colors.ACCENT}\\2{Colors.TEXT}\\3{Colors.Reset}', ip_addr)

#-----| CPU/RAM |-----#
_free_mem = check_output(['free', '-mh']).decode()
for line in _free_mem.split('\n'):
   parts = line.split()
   if 'Mem' not in parts[0]:
      continue

   mem_total = parts[1]
   mem_used = parts[2]
   break

free_mem = f'{Colors.TEXT}{mem_used}/{mem_total}{Colors.Reset}'

_free_cpu = check_output(['top', '-n', '1']).decode()
for line in _free_cpu.split('\n'):
   parts = line.split()
   if 'Cpu(s)' not in line:
      continue

   free_cpu = parts[1].split()[0]
   break

free_cpu = f'{Colors.TEXT}{free_cpu}%{Colors.Reset}'

#-----| Temperature |-----#
_temp = check_output(['sensors']).decode()
for idx,line in enumerate(_temp.split('\n')):
   if idx == 2:
      parts = line.split()
      temp = parts[3]
      temp_high = parts[6]
      temp_crit = parts[9]

float_temp = float(re.sub(r'[^\d\.]', '', temp))
float_temp_high = float(re.sub(r'[^\d\.]', '', temp_high))
float_temp_crit = float(re.sub(r'[^\d\.]', '', temp_crit))

temp_color = None
if float_temp < float_temp_high:
   temp_color = Colors.GOOD
elif float_temp >= float_temp_high and float_temp < float_temp_crit:
   temp_color = Colors.WARN
elif float_temp >= float_temp_crit:
   temp_color = Colors.CRIT

#-----| Uptime |-----#
with open('/proc/uptime') as f:
   _uptime = f.read()

_uptime = round(float(_uptime.split()[0]), 0)
uptime = str(timedelta(seconds=_uptime))

#==============================================================================
#                                Format & Print
#------------------------------------------------------------------------------
print(f'{Colors.BG}{"─"*50:^{WIDTH}}{Colors.Reset}')
print(f'{"Welcome":>{CENTER-3}}  :  {Colors.FG}{user}{Colors.Reset}')
print(f'{Colors.BG}{"─" * 27:^{WIDTH}}{Colors.Reset}')

print(f'{"Uptime":>{CENTER-3}}     {Colors.ACCENT}{uptime}{Colors.Reset}')
print(f'{"IP Addr":>{CENTER-3}}     {ip_addr}')
print(f'{"Sys":>{CENTER-3}}     {free_cpu} {temp_color}{temp} {Colors.BG}CPU{Colors.Reset}')
print(f'{" ":>{CENTER-3}}     {free_mem} {Colors.BG}RAM{Colors.Reset}')
print(f'{Colors.BG}{"─"*50:^{WIDTH}}{Colors.Reset}\n')
