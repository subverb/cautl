if [ "$NO_CERT_SYNC" != 1 ]; then
	if [ -n "${CA_SYNC_PRE}" ]; then
		${CA_SYNC_PRE}
	fi
	declare -g ca_synced=1
fi
