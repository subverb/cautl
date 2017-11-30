CSR=$($GETCACONF -k name).pem
CERT=$($GETCACONF  -k certificate)
CAUTL_CA_ARG=-selfsign
CAUTL_CA_EXTENSION=ca_ext

sv_call_subverb sign $CSR $CERT

