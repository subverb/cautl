local TARGET=$1

PINARGS=
handle_pin SO_PIN --pin
handle_pin PIN --passphrase

echo Pushing Certificate to slot $TARGET
echo pkcs15-init --delete-objects privkey,pubkey --id $TARGET --store-private-key $PRIVDIR/$CA_FILEBASENAME.p12 --format pkcs12 --auth-id $READER_SO_AUTH_ID --verify-pin $PINARGS
pkcs15-init --delete-objects privkey,pubkey --id $TARGET --store-private-key $PRIVDIR/$CA_FILEBASENAME.p12 --format pkcs12 --auth-id $READER_SO_AUTH_ID --verify-pin $PINARGS
