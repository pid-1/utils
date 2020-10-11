#!/bin/bash
# _conf.sh
#
# Completion script for `conf`
# Parses the .json config file to pull out the nicknames.

function _conf_completion ()
{
}

complete -F _conf_completion conf
