GETCONF="openssl_getconf -f $OPENSSL_CONF" 
DEFAULTCA=$($GETCONF -k default_ca)
GETCACONF="$GETCONF -s $DEFAULTCA"