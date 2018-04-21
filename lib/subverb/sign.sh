NEWCSRDIR=$($GETCACONF  -k new_certs_dir)
PRIVKEY=$($GETCACONF -k private_key)

SV_OPTION[certificate]="CERT"

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

openssl ca -config $OPENSSL_CONF -in $NEWCSRDIR/$CSR -out $CERT -passin file:${PRIVKEY}.pwd -extensions ${CAUTL_CA_EXTENSION-sub_ca_ext} ${CAUTL_CA_ARG}
