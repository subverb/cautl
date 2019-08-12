SV_HELP="Erase and Personalize a card"
SV_GROUP=CardHandling
SV_HANDLE_HELP=sourced

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi


