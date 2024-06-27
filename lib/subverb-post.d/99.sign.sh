if [ "$ca_synced" == "1" -a -n "${CA_SYNC_POST}" ]; then
	${CA_SYNC_POST}
fi
