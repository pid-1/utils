#!/bin/bash
# Symlinks conf to /etc/bash_completion.d/

PROGDIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd )"

for compfile in $(ls "$PROGDIR") ; do
   [[ "$compfile" == "deploy.sh" ]] && continue
   sudo ln -s "${PROGDIR}/${compfile}" /etc/bash_completion.d/
done
