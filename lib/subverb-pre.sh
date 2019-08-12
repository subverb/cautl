export UTF8=1
export NAMED_CONSTRAINTS=1
CAUTL_GROUP=${CAUTL_GROUP:-default}
CAUTL_DESCRIPTION="Easy certificate handling and introspection"

SVH_AUTHOR="Benjamin Tietz <benjamin@micronet24.de>"
SVH_LICENSE="GPLv2"

SV_OPTION=(
	[opensslconf]=OPENSSL_CONF
	[group]=CAUTL_GROUP
	[config-type]=CAUTL_CONFIG_TYPE
)

SV_SHORT_OPTION=(
	[F]=OPENSSL_CONF
	[g]=CAUTL_GROUP
	[c]=CAUTL_CONFIG_TYPE
)

SV_OPTION_HELP=(
	[CAUTL_CONFIG_TYPE]="add a suffix for alternate configuration overrides"
	[OPENSSL_CONF]="temporary openssl configuration file to use"
	[CAUTL_GROUP]="configuration and certificate store selection"
)

CA_ALGO="rsa"

. $(sv_default_dir pkglib)/functions.sh
. $(sv_default_dir pkglib)/template.sh

