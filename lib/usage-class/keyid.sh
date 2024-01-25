declare -g CARD_ID

SV_OPTION[principal]="PRINCIPAL"
SV_OPTION_HELP[PRINCIPAL]="The name of the AD-prinicipal to authenticate (for ad_login)"

SV_OPTION[cardid]="CARD_ID"
SV_OPTION_HELP[CARD_ID]="Identifier for the card"

sv_parse_options "$@"

ADD_OID[cautlCardID]=1.3.6.1.4.1.43931.3.2

echo "Add CARD_ID: ${CARD_ID}"
# CARD_ID is supplied for the openssl.cnf template
