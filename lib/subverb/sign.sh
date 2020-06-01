SV_HELP="sign a given certificate"
SV_GROUP=CA_handling
SV_HANDLE_HELP=sourced

NEWCSRDIR=$($GETCACONF  -k new_certs_dir)
PRIVKEY=$($GETCACONF -k private_key)

SV_OPTION[certificate]="CERT"

SV_OPTION[subject-alt-name]="SIGN_SAN"
SV_SHORT_OPTION[n]="SIGN_SAN"
SV_OPTION_HELP[SIGN_SAN]="provide a subjectAltName (must contain the type prefix)"

SV_OPTION[host]="SIGN_HOST"
SV_SHORT_OPTION[h]="SIGN_HOST"
SV_OPTION_HELP[SIGN_HOST]="provide a hostname (relative to the current domain)"

SV_OPTION[fqdn-host]="SIGN_FQDN"
SV_SHORT_OPTION[H]="SIGN_FQDN"
SV_OPTION_HELP[SIGN_FQDN]="provide a (fqdn) hostname"

SV_OPTION[usage-class]="USAGE_CLASS"
SV_SHORT_OPTION[u]="USAGE_CLASS"
SV_OPTION_HELP[USAGE_CLASS]="provide a comma seperated list of usage classes, the certificate should be used for"

NO_DEFAULT_USAGES=0
SV_OPTION[no-default-usage-class]=":NO_DEFAULT_USAGES"
SV_OPTION_HELP[NO_DEFAULT_USAGES]="don't incorporate default usage classes for this certificate"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

CSR="${SV_UNPARSED[0]}"

_parse_option_helper() {
	shift
	sv_parse_options "$@"
}

_parse_option_helper "${SV_UNPARSED[@]}"


if [ -z "$CSR" ]; then
	echo "Please provide the name of the CSR to sign. Optionally also the path to the CERTificate" 1>&2
	exit 1
fi
if [ -z "$CERT" ]; then
	CERT=$($GETCACONF -k certs)/$CSR
fi

if [ -n "${SIGN_SAN}${SIGN_HOST}${SIGN_FQDN}" ]; then
	SIGN_PRESENT=1
fi

declare -gA EXT_KEY_USAGES
declare -gA KEY_USAGES
declare -ga SANS
declare -gA ADD_OID
ADD_OID[cautlUsages]=1.3.6.1.4.1.43931.3.1
if [ $NO_DEFAULT_USAGES -gt 0 ]; then
	CA_ALL_USAGE=
else
	KEY_USAGES[digitalSignature]=1
	KEY_USAGES[keyEncipherment]=1
	KEY_USAGES[nonRepudiation]=1
	EXT_KEY_USAGES[clientAuth]=1
fi

declare defaultIFS=$IFS
IFS=,
usage_classes="${USAGE_CLASS},${CA_ALL_USAGE}"
for cls in ${usage_classes}; do
	if [ -z "$cls" ]; then continue; fi
	IFS=$defaultIFS
	sv_backend --backend "usage-class" --mandatory $cls -- "${SV_UNPARSED[@]}"
	IFS=,
done
KEY_USAGE="${!KEY_USAGES[*]}"
echo "KEY_USAGE: ${KEY_USAGE}"
EXT_KEY_USAGE="${!EXT_KEY_USAGES[*]}"
echo "EXT_KEY_USAGE: ${EXT_KEY_USAGE}"
printf -v IFS "\n"
SIGN_SAN="${SANS[*]}"
IFS=$defaultIFS

generate_configfile ${CAUTL_GROUP}

openssl ca -config $CAUTL_GENERATED_FILE -in $NEWCSRDIR/$CSR -out $CERT -passin file:${PRIVKEY}.pwd -extensions ${CAUTL_CA_EXTENSION-sub_ca_ext} ${CAUTL_CA_ARG}
