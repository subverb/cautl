local TARGET=$1
local WITH_KEY=1
if [ "$2" = "--no-key" ]; then
	WITH_KEY=0
fi

PINARGS=
handle_pin SO_PIN --pin
handle_pin PIN --passphrase

if [ -z "$CERTDIR" ]; then
	CERTDIR=$($GETCACONF -k certs)
fi

local pkcs_args
if [ $WITH_KEY -eq 1 ]; then
	pkcs_args="--delete-objects privkey,pubkey --id $TARGET --store-private-key $PRIVDIR/$CA_FILEBASENAME.p12 --format pkcs12"
else
	pkcs_args="--id $TARGET --store-certificate $CERTDIR/$CA_FILEBASENAME.pem --update-existing"
fi

ERROUTFILE=$(tempfile -p cautl)
echo Pushing Certificate to slot $TARGET
echo pkcs15-init $pkcs_args --auth-id $READER_SO_AUTH_ID --verify-pin $PINARGS
UPLOADED=0
while [ $UPLOADED == 0 ]; do
	pkcs15-init $pkcs_args --auth-id $READER_SO_AUTH_ID --verify-pin $PINARGS 2>${ERROUTFILE} 
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
