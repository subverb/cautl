SV_HELP="Generate a certificate signing request"
SV_GROUP=CertHandling
SV_HANDLE_HELP=sourced

if [ "$1" == "_help_source_" ]; then
	return 0
fi

NAME=$($GETCACONF -k name).pem
CSRDIR=$($GETCACONF  -k new_certs_dir)
PRIVKEY=$($GETCACONF -k private_key)
if [ -f "${PRIVKEY}" ]; then
	read -p "private key for ${NAME} already exists. Really overwrite? [yN]" -n 1 FORCE_OVERWRITE
	if [ $? -ne 0 -o "${FORCE_OVERWRITE,,}" != "y" ]; then
		echo
		echo aborted on user requested
		exit 1
	fi
	echo
	rm -f ${PRIVKEY} ${PRIVKEY}.pwd
fi

openssl rand -base64 32 > ${PRIVKEY}.pwd
chmod 400 ${PRIVKEY}.pwd

openssl req -new -config $OPENSSL_CONF -out $CSRDIR/$NAME -keyout $PRIVKEY -passout file:${PRIVKEY}.pwd
