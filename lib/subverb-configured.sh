if [ -n "${CAUTL_CONFIG_TYPE}" ]; then
	parse_config "$(sv_default_dir sysconf).${CAUTL_CONFIG_TYPE}"
	parse_config "$HOME/.${SVBASE}.${CAUTL_CONFIG_TYPE}"
fi

generate_configfile ${CAUTL_GROUP}

OPENSSL_CONF=${CAUTL_GENERATED_FILE}

GETCONF="openssl_getconf -f $OPENSSL_CONF" 
DEFAULTCA=$($GETCONF -k default_ca)
GETCACONF="$GETCONF -s $DEFAULTCA"
