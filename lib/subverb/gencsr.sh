SV_HELP="Generate a certificate signing request"
SV_GROUP=CertHandling
SV_HANDLE_HELP=sourced

if [ "$1" == "_help_source_" ]; then
	return 0
fi

NAME=$($GETCACONF -k name).pem
CSRDIR=$($GETCACONF  -k new_certs_dir)
PRIVKEY=$($GETCACONF -k private_key)

openssl rand -base64 32 > ${PRIVKEY}.pwd
chmod 400 ${PRIVKEY}.pwd

openssl req -new -config $OPENSSL_CONF -out $CSRDIR/$NAME -keyout $PRIVKEY -passout file:${PRIVKEY}.pwd
