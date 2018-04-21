CRL=$($GETCACONF  -k crl)
PRIVKEY=$($GETCACONF -k private_key)

openssl ca -gencrl -config $OPENSSL_CONF -out $CRL -passin file:${PRIVKEY}.pwd
