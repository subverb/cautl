SV_HELP="Generate a certificate signing request"
SV_GROUP=CertHandling
SV_HANDLE_HELP=sourced

SV_OPTION[name]="OPT_NAME"
SV_OPTION_HELP[OPT_NAME]="generate the CSR for a different name. Default is to generate the CSR for the current configuration"

SV_OPTION[commonname]="OPT_COMMONNAME"
SV_OPTION_HELP[OPT_COMMONNAME]="If set, the common-name field for the generated CSR will be set to the given value (Depends on --name)"

SV_OPTION[keylen]="OPT_KEYLEN"
SV_OPTION_HELP[OPT_KEYLEN]="specify the length of the generated key (default is $CA_BITSIZE)"

SV_OPTION[group]="OPT_GROUP"
SV_OPTION_HELP[OPT_GROUP]="use a different cautl-group when generating this CSR"

OPT_IFNEXISTS=0
SV_OPTION[if-not-exists]=":OPT_IFNEXISTS"
SV_OPTION_HELP[OPT_IFNEXISTS]="don't create a csr (and exit silently), if it already exists"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

if [ -n "${OPT_NAME}${OPT_KEYLEN}${OPT_GROUP}" ]; then
	if [ -n "${OPT_NAME}" ]; then
		CA_NAME=$OPT_NAME
		if [ -n "${OPT_COMMONNAME}" ]; then
			CA_COMMONNAME="${OPT_COMMONNAME}"
		fi
	fi
	if [ -n "${OPT_KEYLEN}" ]; then
		CA_BITSIZE=${OPT_KEYLEN}
	fi
	if [ -n "${OPT_GROUP}" ]; then
		CAUTL_GROUP=${OPT_GROUP}
	fi
	generate_configfile ${CAUTL_GROUP}
else
	CAUTL_GENERATED_FILE=$OPENSSL_CONF
fi

NAME=$($GETCACONF -f ${CAUTL_GENERATED_FILE} -k name).pem
CSRDIR=$($GETCACONF  -f ${CAUTL_GENERATED_FILE} -k new_certs_dir)
PRIVKEY=$($GETCACONF -f ${CAUTL_GENERATED_FILE} -k private_key)

if [ -f "${PRIVKEY}" ]; then
	if [ ${OPT_IFNEXISTS} -gt 0 ]; then
		exit 0
	fi
	read -p "private key for ${NAME} already exists. Really overwrite? [yN]" -n 1 FORCE_OVERWRITE
	if [ $? -ne 0 -o "${FORCE_OVERWRITE,,}" != "y" ]; then
		echo
		echo aborted on user requested
		exit 1
	fi
	echo
	rm -f ${PRIVKEY} ${PRIVKEY}.pwd
fi

openssl rand -base64 32 > ${PRIVKEY}.pwd
chmod 400 ${PRIVKEY}.pwd

openssl req -new -config ${CAUTL_GENERATED_FILE} -out $CSRDIR/$NAME -keyout $PRIVKEY -passout file:${PRIVKEY}.pwd
