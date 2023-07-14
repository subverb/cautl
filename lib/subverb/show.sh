#!/bin/false
SV_HELP="show the contents of a certificate"
SV_GROUP=CertHandling
SV_HANDLE_HELP=sourced

options_cert_name_type

SV_OPTION[file]="CERT_FILE"
SV_OPTION[uri]="CERT_FILE"
SV_SHORT_OPTION[f]="CERT_FILE"
SV_SHORT_OPTION[u]="CERT_FILE"
SV_OPTION_HELP[CERT_FILE]="explicit filename (or URI of a SSL/TLS-Server) of certificate to show. This will override --name and --type"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

CERT_BASE="${CERT_FILE}"
if [ -z "$CERT_FILE" ]; then
	if ! test_cert_name_type; then
		echo "Either --name or --file must be given" >&2
		exit 1
	fi
	CERT_BASE="$CERT_NAME"
	CERT_FILE=$(cert_name2file)
fi

if [[ ! "${CERT_FILE}" =~ "://" ]] && [[ ! -f "$CERT_FILE" ]]; then
	echo "Certificate ${CERT_BASE} not found!" >&2
	exit 1
fi

PEM_SEPARATOR="-----"
FILETYPE=
COMMON_ARGS="-text -noout"

uri_regex='^([-a-zA-Z0-9]+)://([-_a-zA-Z0-9]+)(:([0-9]+))?'
case "${CERT_FILE}" in
	*://*)
		HOST=
		PORT=
		if [[ "${CERT_FILE}" =~ $uri_regex ]]; then
			PROTO=${BASH_REMATCH[1]};
			HOST=${BASH_REMATCH[2]};
			PORT=${BASH_REMATCH[4]};
			if [ -z "$PORT" ]; then
				PORT=$(getent services ${PROTO} | grep tcp | sed -e "s/${PROTO}\\s*//;s,/tcp,,")
			fi
		else
			echo "Unkown URI-format '${CERT_FILE}'" >&2
			exit 1
		fi
		FILETYPE=CERTIFICATE
		CERT_FILE=$(mktemp --tmpdir cautl_XXXXXXXX.pem)
		trap_add "rm ${CERT_FILE}" EXIT
		openssl s_client -connect ${HOST}:${PROTO} </dev/null 2>/dev/null | sed -ne "/${PEM_SEPARATOR}BEGIN ${FILETYPE}${PEM_SEPARATOR}/,/${PEM_SEPARATOR}END ${FILETYPE}${PEM_SEPARATOR}/p" > "$CERT_FILE"
		;;
	*.pem|*.crt)
		FILETYPE=$(grep -e "$PEM_SEPARATOR" "${CERT_FILE}" | head -n 1 | sed -e 's/-//g;s/^.*BEGIN\s*//i;s/\W*$//')
		;;
	*.p12|*.pfx)
		FILETYPE="PKCS#12"
		COMMON_ARGS=""
		;;
	*)
		FILETYPE="unknown"
		;;
esac

echo "Certificate-type: $FILETYPE"
case "$FILETYPE" in
	"")
		echo "No certificate start found!">&2
		exit 1
		;;
	"ENCRYPTED PRIVATE KEY")
		OPENSSL_SUBCMD="rsa -check"
		if [ -f "${CERT_FILE}.pwd" ]; then
			OPENSSL_SUBCMD="${OPENSSL_SUBCMD} -passin file:${CERT_FILE}.pwd"
		fi
		;;
	"RSA PRIVATE KEY")
		OPENSSL_SUBCMD="rsa"
		;;
	"PUBLIC KEY")
		OPENSSL_SUBCMD="rsa -pubin"
		;;
	"RSA PUBLIC KEY")
		OPENSSL_SUBCMD="rsa -RSAPublicKey_in"
		;;
	"CERTIFICATE")
		OPENSSL_SUBCMD="x509"
		for i in md5 sha1 sha256; do
			openssl $OPENSSL_SUBCMD -noout -fingerprint -$i -in ${CERT_FILE}
		done
		;;
	"X509 CRL")
		OPENSSL_SUBCMD="crl"
		if [ -n "${CERT_NAME}" && -f "$CA_HOME/certs/${CERT_NAME}" ]; then
			openssl crl -noout -in $CERT_FILE -CAfile "$CA_HOME/certs/${CERT_NAME}"
		fi
		;;
	"CERTIFICATE REQUEST"|"NEW CERTIFICATE REQUEST")
		OPENSSL_SUBCMD="req -verify"
		;;
	"PKCS#12")
		OPENSSL_SUBCMD="pkcs12 -info -nodes"
		;;
	*)
		echo "Unknown certificate type '$FILETYPE'" >&2
		exit 1
		;;
esac

openssl $OPENSSL_SUBCMD $COMMON_ARGS -in ${CERT_FILE}
