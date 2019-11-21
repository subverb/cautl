SV_HELP="Erase and Personalize a card"
SV_GROUP=CardHandling
SV_HANDLE_HELP=sourced

SV_OPTION[label]="CA_LABEL"
SV_SHORT_OPTION[l]="CA_LABEL"
SV_OPTION_HELP[CA_LABEL]="Specify a free-form label"

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

SV_OPTION[so-puk]="CA_SO_PUK"
SV_SHORT_OPTION[K]="CA_SO_PUK"
SV_OPTION_HELP[CA_SO_PUK]="specify a security officer puk (SO_PUK) to set"

SV_OPTION[algorithm]="CA_ALGO"
SV_SHORT_OPTION[a]="CA_ALGO"
SV_OPTION_HELP[CA_ALGO]="algorithm to use for key generation"

SV_OPTION[bitsize]="CA_CARD_BITSIZE"
SV_SHORT_OPTION[b]="CA_CARD_BITSIZE"
SV_OPTION_HELP[CA_CARD_BITSIZE]="size of the key to generate"

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

local DATADIR=$(sv_default_dir pkgdata)
PREGEN_FILE=${CAUTL_GENERATED_FILE}
template2tempfile $DATADIR < $DATADIR/personalize-card
CONFFILE=${CAUTL_GENERATED_FILE}
CAUTL_GENERATED_FILE=${PREGEN_FILE}

echo "Erasing card"
sv_backend --backend "$CARD_BACKEND" --optional erase -- $CONFFILE

echo "Setting pins"
if [ -n "$SO_PIN" ]; then
	sv_backend --backend "$CARD_BACKEND" --mandatory set-pin -- --current "$DEFAULT_SOPIN" --pin "$SO_PIN" --puk "$SO_PUK" --type so --conffile $CONFFILE
else
	SO_PIN=$DEFAULT_SOPIN
fi
if [ -n "$PIN" ]; then
	sv_backend --backend "$CARD_BACKEND" --mandatory set-pin -- --current "$DEFAULT_PIN" --pin "$PIN" --puk "$PUK" --type user --conffile $CONFFILE
fi

PRIVDIR=$(dirname $($GETCACONF -k private_key))
if [ "$CERT_GENERATION" = "onhost" ]; then
	( trap "" EXIT; sv_call_subverb gencsr --name $CA_FILEBASENAME --commonname "${CA_LABEL##CN=}" --keylen $CA_CARD_BITSIZE --group $READER_GROUPTYPE ) # force a subshell here
	if [ $? -ne 0 ]; then
		exit 1
	fi
	SIGN_ARGS=$CA_FILEBASENAME.pem
	if [ "$cert_type" = "host" ]; then
		SIGN_ARGS="--fqdn-host '${CA_LABEL##CN=}' $SIGN_ARGS"
	fi
	sv_call_subverb sign $SIGN_ARGS
	PIN=$PIN sv_call_subverb convert --type private --name $CA_FILEBASENAME.pem --to p12 --passout env:PIN #XXX add intermediate certificate
	for i in "${READER_CERT_TARGET[@]}"; do
		sv_backend --backend "$CARD_BACKEND" --mandatory pushsignedkey -- $i
	done
else
	echo "On-key generation of certificates is untested" 1>&2
	sv_backend --backend "$CARD_BACKEND" --mandatory createcert -- $CONFFILE $READER_DEFAULT_ID
	sv_backend --backend "$CARD_BACKEND" --optional getpubkey
fi

cp --backup=numbered $CONFFILE $PRIVDIR/$CA_FILEBASENAME.conf
