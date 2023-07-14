SV_HELP="replace the certificate on a card"
SV_GROUP=CardHandling
SV_HANDLE_HELP=sourced

SV_OPTION[label]="CA_FILEBASENAME"
SV_SHORT_OPTION[l]="CA_FILEBASENAME"
SV_OPTION_HELP[CA_FILEBASENAME]="specify the certificate to load onto the key. Otherwise it will be selected based on the public key on the Card."

CA_RESIGN=0
SV_OPTION[resign]=":CA_RESIGN"
SV_OPTION_HELP[CA_RESIGN]="sign the certificate, before loading it to the key"

CA_SETPIN=0
SV_OPTION[setpin]=":CA_SETPIN"
SV_OPTION_HELP[CA_SETPIN]="(re-)set the smartcard pins as well"


sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

declare -a ADDITIONAL_ARGS=( "${SV_UNPARSED[@]}" )

PRIVDIR=$(dirname $($GETCACONF -k private_key))

declare CARD_BACKEND
sv_backend --group card --one --mandatory initreader
if [ -z "$CARD_BACKEND" ]; then
	echo "No card-backend found!" 1>&2
	exit 1
fi

if [ -z "$CA_FILEBASENAME" ]; then
	CA_FILEBASENAME=$(sv_backend --backend "$CARD_BACKEND" --mandatory identify)
	CA_LABEL="CN=${CA_FILEBASENAME}"
	if [ ! -f "${PRIVDIR}/${CA_FILEBASENAME}.conf" ]; then
		CA_FILEBASENAME=$(basename -s ".${CA_DOMAIN}" "${CA_FILEBASENAME}" )
	fi
else
	CA_FILEBASENAME=$(basename -s ".pem" "${CA_FILEBASENAME}" )
	CA_LABEL="CN=$(openssl x509 -text -noout -in "$($GETCACONF -k certs)/${CA_FILEBASENAME}.pem" | sed -ne '/Subject:/{s/.*CN\s*=\s*//;p}')"
	CA_LABEL="CN=${CA_FILEBASENAME}"
fi
if [ ! -f "${PRIVDIR}/${CA_FILEBASENAME}.conf" ]; then
	echo "No data for certificate ${CA_FILEBASENAME} available!" 1>&2
	exit 1
fi

check_pin() {
	local type=$1
	local var=$2
	local length=$3
	local maxlength=${4:-$length}

	local label=$(echo ${type} | tr A-Z_ a-z-)
	sed -ne "/^${label}=/{s/.*=\\s*//;p}" "${PRIVDIR}/${CA_FILEBASENAME}.conf" | tr -d "\012"
}

local PIN=$(check_pin PIN "$CA_PIN" $READER_PIN_MIN $READER_PIN_MAX)
local PUK=$(check_pin PUK "$CA_PUK" $READER_PIN_MIN $READER_PIN_MAX)
local SO_PIN=$(check_pin SO-PIN "$CA_SO_PIN" $READER_SOPIN_MIN $READER_SOPIN_MAX)
local SO_PUK=$(check_pin SO-PUK "$CA_SO_PUK" $READER_SOPIN_MIN $READER_SOPIN_MAX)

local DATADIR=$(sv_default_dir pkgdata)

if [ $CA_SETPIN -gt 0 ]; then
	CONFFILE="${PRIVDIR}/${CA_FILEBASENAME}.conf"
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
fi

if [ "$CERT_GENERATION" = "onhost" ]; then
	if [ $CA_RESIGN -gt 0 ]; then
		SIGN_ARGS=$CA_FILEBASENAME.pem
		if [[ "$CA_LABEL" =~ "$CA_DOMAIN" ]]; then
			SIGN_ARGS="--fqdn-host '${CA_LABEL##CN=}' $SIGN_ARGS"
		fi
		sv_call_subverb sign $SIGN_ARGS "${ADDITIONAL_ARGS[@]}"
	fi
	PIN=$PIN sv_call_subverb convert --type private --name $CA_FILEBASENAME.pem --to p12 --passout env:PIN #XXX add intermediate certificate
	for i in "${READER_CERT_TARGET[@]}"; do
		sv_backend --backend "$CARD_BACKEND" --mandatory pushsignedkey -- $i
	done
else
	echo "On-key update of certificates is untested" 1>&2
	sv_backend --backend "$CARD_BACKEND" --optional getpubkey
	sv_backend --backend "$CARD_BACKEND" --optional pushcertificate
fi
