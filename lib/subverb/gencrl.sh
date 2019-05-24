SV_HELP="Generate Certificate revocation list for the current certificate authority"
SV_GROUP=CA_handling
SV_HANDLE_HELP=sourced
CRL=$($GETCACONF  -k crl)
PRIVKEY=$($GETCACONF -k private_key)

if [ "$1" == "_help_source_" ]; then
	return 0
fi

openssl ca -gencrl -config $OPENSSL_CONF -out $CRL -passin file:${PRIVKEY}.pwd
