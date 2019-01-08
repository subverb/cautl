SV_HELP="sign a given certificate"
SV_GROUP=CA_handling

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


sv_parse_options "$@"

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

generate_configfile ${CAUTL_GROUP}

openssl ca -config $CAUTL_GENERATED_FILE -in $NEWCSRDIR/$CSR -out $CERT -passin file:${PRIVKEY}.pwd -extensions ${CAUTL_CA_EXTENSION-sub_ca_ext} ${CAUTL_CA_ARG}
