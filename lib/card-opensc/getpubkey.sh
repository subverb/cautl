# read public key

case "$READER_SUPPORT_PUBKEY" in
	"pkcs11")
		pkcs11-tool --slot-index $READER_ID --id $READER_DEFAULT_ID --read-object --type pubkey | openssl rsa -inform DER -outform PEM -pubin -out $NEWCSRDIR/$CA_FILEBASENAME.pub
		;;
	"pkcs15")
		pkcs15-tool --reader $READER_ID --read-public-key $READER_DEFAULT_ID > $NEWCSRDIR/$CA_FILEBASENAME.pub
		;;
	*)
		echo reading pubkey via $READER_SUPPORT_PUBKEY not supported
		;;
esac
