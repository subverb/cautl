SV_OPTION=(
	[opensslconf]=OPENSSL_CONF
)

SV_SHORT_OPTION=(
	[F]=OPENSSL_CONF
)

. $(sv_default_dir pkglib)/template.sh

if [ -z "$OPENSSL_CONF" -a -n "$CAUTL_SYSCONFIG" ]; then
	OPENSSL_CONF=${CAUTL_SYSCONFIG}.cnf
fi
