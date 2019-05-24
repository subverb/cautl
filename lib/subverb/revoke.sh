SV_HELP="Revoke current certificate"
SV_GROUP=CertHandling
SV_HANDLE_HELP=sourced

if [ "$1" == "_help_source_" ]; then
	return 0
fi

CERT=$($GETCACONF -k certs)/$1
REASON=$2

if [ -z "$CERT" -o -z "$REASON" ]; then
	echo "Usage: $0 revoke CERT REASON" 1>&2
	exit 1
fi

openssl ca -config $OPENSSL_CONF -revoke $CERT -crl_reason $REASON -passin file:${PRIVKEY}.pwd
