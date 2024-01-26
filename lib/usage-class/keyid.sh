declare -g CARD_ID

SV_OPTION[principal]="PRINCIPAL"
SV_OPTION_HELP[PRINCIPAL]="The name of the AD-prinicipal to authenticate (for ad_login)"

SV_OPTION[cardid]="CARD_ID"
SV_OPTION_HELP[CARD_ID]="Identifier for the card"

sv_parse_options "$@"

ADD_OID[cautlCardID]=1.3.6.1.4.1.43931.3.2

if [ -z "${CARD_ID}" -a -n "${CERT}" -a -f "${CERT}" ]; then
	OFFSET=$(sed -ne '/--- *BEGIN/,/--- *END/p' ${CERT} | openssl asn1parse -inform PEM | grep -e "1.3.6.1.4.1.43931.3.2" -e "cautlCardID" -A 1 | sed -e 's/:.*//' | tail -n 1)
	if [ -n "$OFFSET" ]; then
		CARD_ID="$(sed -ne '/--- *BEGIN/,/--- *END/p' ${CERT} | openssl asn1parse -inform PEM -strparse $OFFSET | sed -ne '/UTF8STRING/{s/.*UTF8STRING\s*://;p}')"
	fi
fi

echo "Add CARD_ID: ${CARD_ID}"
# CARD_ID is supplied for the openssl.cnf template
