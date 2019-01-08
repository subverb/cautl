SV_HELP="self-sign the master certificate"
SV_GROUP=CertHandling
CSR=$($GETCACONF -k name).pem
CERT=$($GETCACONF  -k certificate)
CAUTL_CA_ARG=-selfsign
CAUTL_CA_EXTENSION=ca_ext

sv_call_subverb sign $CSR --certificate $CERT

