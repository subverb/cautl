SV_OPTION=(
	[key]=ENV_KEY
	[section]=ENV_SECTION
	);
SV_SHORT_OPTION=(
	[k]=ENV_KEY
	[s]=ENV_SECTION
	);

sv_parse_options "$@"

ARGS=
if [ -n "$ENV_SECTION" ]; then
	ARGS="$ARGS -s $ENV_SECTION"
fi
if [ -n "$OPENSSL_CONF" ]; then
	ARGS="$ARGS -f $OPENSSL_CONF"
fi
if [ -z "$ENV_KEY" ]; then
	echo "no key given" 1>&2
	exit 1
fi
openssl_getconf $ARGS -k $ENV_KEY
