SV_HELP="Erase and Personalize a card"
SV_GROUP=CardHandling
SV_HANDLE_HELP=sourced

SV_OPTION[label]="CA_LABEL"
SV_SHORT_OPTION[l]="CA_LABEL"
SV_OPTION_HELP[CA_INFILE]="Specify a free-form label"

SV_OPTION[user-label]="CA_USER_LABEL"
SV_SHORT_OPTION[u]="CA_USER_LABEL"
SV_OPTION_HELP[CA_USER_LABEL]="Specify a username as label"

SV_OPTION[host-label]="CA_HOST_LABEL"
SV_SHORT_OPTION[h]="CA_HOST_LABEL"
SV_OPTION_HELP[CA_HOST_LABEL]="Specify a hostname to use as label for a machine-certificate"

CA_LOCALHOST=0
SV_OPTION[localhost]=":CA_LOCALHOST"
SV_OPTION_HELP[CA_LOCALHOST]="generate a key to authenticate the local host"

CA_NOLABEL=0
SV_OPTION[no-label]=":CA_NOLABEL"
SV_OPTION_HELP[CA_NOLABEL]="Don't specify a label for the key"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

declare -g cert_type="generic"
declare -g CA_FILEBASENAME="$CA_LABEL"

if [ -z "$CA_LABEL" -a -n "$CA_USER_LABEL" ]; then
	CA_LABEL="CN=$CA_USER_LABEL" # XXX might as well be UID=, but depends on openssl.cnf
	CA_FILEBASENAME="user_$CA_USER_LABEL"
	cert_type="user"
fi

if [ -z "$CA_LABEL" ]; then
	local cert_type="host"
	CA_FILEBASENAME="$CA_HOST_LABEL"
	case "$CA_HOST_LABEL" in
		*.*)
			CA_LABEL="CN=$CA_HOST_LABEL"
			;;
		"")
			if [ $CA_LOCALHOST -gt 0 ]; then
				CA_LABEL="CN=$CA_HOST.$CA_DOMAIN"
				CA_FILEBASENAME="$CA_HOST"
			fi
			;;
		*)
			CA_LABEL="CN=$CA_HOST_LABEL.$CA_DOMAIN"
			;;
	esac
fi

if [ -z "$CA_LABEL" ]; then
	echo "No label specified for personalization" 1>&2
	if [ $CA_NOLABEL -le 0 ]; then
		exit 1
	fi
fi


