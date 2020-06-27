SV_HELP="Run an OCSP resolver"
SV_GROUP=OCSP
SV_HANDLE_HELP=sourced

SV_OPTION[dir]=OCSP_DIRECTORY
SV_OPTION_HELP[OCSP_DIRECTORY]="define a different OCSP directory to serve. Defaults to the cautl data directory"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

if [ -n "${OCSP_DIRECTORY}" ]; then
	if [ -f "${OCSP_DIRECTORY}/cautl.conf" ]; then
		. "${OCSP_DIRECTORY}/cautl.conf"
	fi
	CA_HOME=${OCSP_DIRECTORY}
fi
CA_NAME=ocsp
generate_configfile
OPENSSL_CONF=${CAUTL_GENERATED_FILE}
GETCONF="openssl_getconf -f $OPENSSL_CONF" 
GETCACONF="$GETCONF -s $DEFAULTCA"

declare OCSP_ARGS
if [ -n "${CA_OCSP_PORT}" ]; then
	OCSP_ARGS="${OCSP_ARGS} -port ${CA_OCSP_PORT}"
else
	echo "Warning: No OCSP-Port specified"
fi

DATABASE=$($GETCACONF -k "database")
CACERTIFICATE=$($GETCACONF -k "certificate")
CERTDIR=$($GETCACONF -k "certs")
PRIVKEY=$($GETCACONF -k "private_key")

openssl ocsp -index ${DATABASE} -CA ${CACERTIFICATE} -ndays ${CAUTL_OCSP_NDAYS:-1} -rsigner ${CERTDIR}/${CA_NAME}.pem -rkey ${PRIVKEY} ${OCSP_ARGS}
