SV_HELP="create or update the ocsp certificate"
SV_GROUP=OCSP
SV_HANDLE_HELP=sourced

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

( trap "" EXIT; sv_call_subverb gencsr --if-not-exists --name ocsp --commonname "OCSP for ${CA_COMMONNAME}" --keylen ${CA_CARD_BITSIZE:-${CA_BITSIZE}} ) # force a subshell here
if [ $? -ne 0 ]; then
	exit 1
fi
sv_call_subverb sign --no-default-usage-class --usage-class OCSPSigning ocsp.pem

