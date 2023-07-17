#!/bin/false
SV_HELP="show the current configuration"
SV_GROUP=Housekeeping
SV_HANDLE_HELP=sourced

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi
env | grep -e ^CAUTL_ -e ^CA_ | sort

