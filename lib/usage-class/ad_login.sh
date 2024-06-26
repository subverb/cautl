SV_OPTION[principal]="PRINCIPAL"
SV_OPTION_HELP[PRINCIPAL]="The name of the AD-prinicipal to authenticate"

sv_parse_options "$@"

if [ -z "${PRINCIPAL}" -a -n "${CERT}" -a -f "${CERT}" ]; then
	SANOFFSET=$(sed -ne '/--- *BEGIN/,/--- *END/p' ${CERT} | openssl asn1parse -inform PEM | grep "X509v3 Subject Alternative Name" -A 1 | sed -e 's/:.*//' | tail -n 1)
	if [ -n "$SANOFFSET" ]; then
		PRINCIPAL=$(sed -ne '/--- *BEGIN/,/--- *END/p' ${CERT} | openssl asn1parse -inform PEM -strparse $SANOFFSET | sed -ne '/UTF8STRING/{s/.*UTF8STRING\s*://;p}')
	fi
fi

if [ -z "$PRINCIPAL" ]; then
	echo "Please specify the principal whom to authenticate using --principal" 1>&2
	exit 1
fi

echo "principal: '$PRINCIPAL'"
PRINCIPAL=${PRINCIPAL/\\/\\\\}
echo "principal: '$PRINCIPAL'"

# Ordinarily, certificates must have this oid as an enhanced key usage in order for Windows to allow them to be used as a login credential
ADD_OID[msSmartcardLogin]=1.3.6.1.4.1.311.20.2.2
# Used in a smart card login certificate's subject alternative name
ADD_OID[msUPN]=1.3.6.1.4.1.311.20.2.3

EXT_KEY_USAGES[msSmartcardLogin]=1

SANS[${#SANS}]="email.1=copy"
SANS[${#SANS}]="otherName.1=msUPN;UTF8:$PRINCIPAL"
