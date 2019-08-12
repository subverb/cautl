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

SV_OPTION[pin]="CA_PIN"
SV_SHORT_OPTION[p]="CA_PIN"
SV_OPTION_HELP[CA_PIN]="specify the user-pin to set"

SV_OPTION[so-pin]="CA_SO_PIN"
SV_SHORT_OPTION[P]="CA_SO_PIN"
SV_OPTION_HELP[CA_SO_PIN]="specify a security officer pin (SO_PIN) to set"

SV_OPTION[puk]="CA_PUK"
SV_SHORT_OPTION[k]="CA_PUK"
SV_OPTION_HELP[CA_PUK]="specify the user-puk to set"

SV_OPTION[so-pin]="CA_SO_PUK"
SV_SHORT_OPTION[K]="CA_SO_PUK"
SV_OPTION_HELP[CA_SO_PUK]="specify a security officer puk (SO_PUK) to set"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

check_pin() {
	local type=$1
	local var=$2
	local length=$3
	local maxlength=${4:-$length}
	local PIN=
	case "$var" in
		env:*)
			var=ENV:${var#env:}
			;& # handle like ENV:*
		ENV:*)
			local -n varref=${var#ENV:}
			PIN=$varref
			;;
		generate|"")
			PIN=${RANDOM:1}
			while [ ${#PIN} -lt $length ]; do
				PIN="$PIN${RANDOM:1}"
			done
			PIN=${PIN:0:$maxlength}
			;;
		none)
			PIN=
			return 0
			;;
		*)
			PIN=$var
			;;
	esac
	if [ -z "$PIN" ]; then
		echo "no valid $type found" 1>&2
		exit 1
	fi
	echo "$PIN"
}

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

declare CARD_BACKEND
sv_backend --group card --one --mandatory initreader
if [ -z "$CARD_BACKEND" ]; then
	echo "No card-backend found!" 1>&2
	exit 1
fi

if [ -z $READER_PIN_MIN ]; then
	echo "minumum PIN-length unknown. Can't update pins!"
fi
local PIN=$(check_pin PIN "$CA_PIN" $READER_PIN_MIN $READER_PIN_MAX)
local PUK=$(check_pin PUK "$CA_PUK" $READER_PIN_MIN $READER_PIN_MAX)
local SO_PIN=$(check_pin SO-PIN "$CA_SO_PIN" $READER_SOPIN_MIN $READER_SOPIN_MAX)
local SO_PUK=$(check_pin SO-PUK "$CA_SO_PUK" $READER_SOPIN_MIN $READER_SOPIN_MAX)


