NEWCSRDIR=$($GETCACONF  -k new_certs_dir)
PRIVKEY=$($GETCACONF -k private_key)

CSR=$1
CERT=${2-$($GETCACONF -k certs)/$CSR}

if [ -z "$CSR" ]; then
	echo "Please provide the name of the CSR to sign. Optionally also the path to the CERTificate" 1>&2
	exit 1
fi

openssl ca -config $OPENSSL_CONF -in $NEWCSRDIR/$CSR -out $CERT -passin file:${PRIVKEY}.pwd -extensions ${CAUTL_CA_EXTENSION-sub_ca_ext} ${CAUTL_CA_ARG}
