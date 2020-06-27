SV_HELP="Export all data necessary for the OCSP resolver to run"
SV_GROUP=OCSP
SV_HANDLE_HELP=sourced

OCSP_DIRECTORY="$HOME/ocsp"
SV_OPTION[dir]=OCSP_DIRECTORY
SV_OPTION_HELP[OCSP_DIRECTORY]="define a different OCSP directory to serve. Defaults to '$OCSP_DIRECTORY'"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

CA_NAME=ocsp
generate_configfile
OPENSSL_CONF=${CAUTL_GENERATED_FILE}
GETCONF="openssl_getconf -f $OPENSSL_CONF" 
GETCACONF="$GETCONF -s $DEFAULTCA"

DATABASE=$($GETCACONF -k "database")
CACERTIFICATE=$($GETCACONF -k "certificate")
CERTDIR=$($GETCACONF -k "certs")
PRIVKEY=$($GETCACONF -k "private_key")

for i in "${DATABASE}" "${DATABASE}.attr" "${CACERTIFICATE}" "${CERTDIR}/${CA_NAME}.pem"; do
	tgt="${OCSP_DIRECTORY}/${i##${CA_HOME}}"
	mkdir -p $(dirname $tgt)
	cp $i $tgt
done

PRIVKEY_TGT="${OCSP_DIRECTORY}/${PRIVKEY##${CA_HOME}}"
mkdir -p "$(dirname ${PRIVKEY_TGT})"

sv_call_subverb convert --name "${CA_NAME}.pem" --type private --out "${PRIVKEY_TGT}" --to "nopwd.pem"

