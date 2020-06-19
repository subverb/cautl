local TARGET=$1

PINARGS=
handle_pin SO_PIN --pin
handle_pin PIN --passphrase

ERROUTFILE=$(tempfile -p cautl)
echo Pushing Certificate to slot $TARGET
echo pkcs15-init --delete-objects privkey,pubkey --id $TARGET --store-private-key $PRIVDIR/$CA_FILEBASENAME.p12 --format pkcs12 --auth-id $READER_SO_AUTH_ID --verify-pin $PINARGS
UPLOADED=0
while [ $UPLOADED == 0 ]; do
	pkcs15-init --delete-objects privkey,pubkey --id $TARGET --store-private-key $PRIVDIR/$CA_FILEBASENAME.p12 --format pkcs12 --auth-id $READER_SO_AUTH_ID --verify-pin $PINARGS 2>${ERROUTFILE} 
	grep -v "Failed to" "${ERROUTFILE}"
	ERRSTR=$(grep "Failed to" ${ERROUTFILE})
	if [ -n "$ERRSTR" ]; then
		case "${CARD_PUSH_SIGN_ERROR[$ERRSTR]}" in
			retry)
				;;
			ignore)
				UPLOADED=1
				;;
			*)
				echo "$ERRSTR" 1>&2
				echo "Error pushing certificate to card!" 1>&2
				exit 1
				;;
		esac
	else
		UPLOADED=1
	fi
	rm ${ERROUTFILE}
done
