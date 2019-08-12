case "$READER_SUPPORT_ERASE" in
	pkcs15)
		pkcs15-init --reader $READER_ID --erase-card
		;;
	openpgp)
		openpgp-tool --reader $READER_ID --erase
		;;
	"")
		echo "Erasing not supported by reader"
		;;
esac

