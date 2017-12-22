CAUTL_GROUP=${CAUTL_GROUP:-default}

SV_OPTION=(
	[opensslconf]=OPENSSL_CONF
	[group]=CAUTL_GROUP
)

SV_SHORT_OPTION=(
	[F]=OPENSSL_CONF
	[g]=CAUTL_GROUP
)

. $(sv_default_dir pkglib)/template.sh

