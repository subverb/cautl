SV_HELP="list all known certificates"
SV_GROUP=CA_handling
SV_HANDLE_HELP=sourced

if [ "$1" == "_help_source_" ]; then
	return 0
fi

sv_backend --group cert --all --mandatory list
