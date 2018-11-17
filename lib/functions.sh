trap_add() {
	cmd=$1
	shift
	for sig in $@; do
		oldtrapcmd="$(trap -p $sig | sed -e "s/^trap -- '//;s/' EXIT//")"
		if [ -n "$oldtrapcmd" ]; then oldtrapcmd="$oldtrapcmd; "; fi
		trap "$oldtrapcmd $cmd" $sig
	done
}
declare -f -t trap_add

###########################################
# identify a certificate by name and type #
#
# This include common options, tests and conversion function to the corresponding filename
#
options_cert_name_type() {
	SV_OPTION[name]="CERT_NAME"
	SV_SHORT_OPTION[n]="CERT_NAME"
	SV_OPTION_HELP[CERT_NAME]="name of the certificate to dump (with suffix)"

	declare -g CERT_TYPE="certs"
	SV_OPTION[type]="CERT_TYPE"
	SV_SHORT_OPTION[t]="CERT_TYPE"
	SV_OPTION_HELP[CERT_TYPE]="certificate type to check - one of [certs, crl, newcerts, private]"
}

test_cert_name_type() {
	[ -n "$CERT_NAME" -a -d "$CA_HOME/$CERT_TYPE" ]
}

cert_name2file() {
	echo "$CA_HOME/$CERT_TYPE/$CERT_NAME"
}

