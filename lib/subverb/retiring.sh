SV_HELP="list all certificates, which will stop working soon"
SV_GROUP=CA_handling
SV_HANDLE_HELP=sourced

SV_DAYS=30
SV_OPTION[days]=SV_DAYS
SV_OPTION_HELP[SV_DAYS]="length of grace-period in days"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

sv_backend --group cert --all --optional retiring

