local CONFFILE=$1
local CERTID=${2:-$READER_DEFAULT_ID}
shift 2

#XXX review, test and maybe migreate to personalize-card.sh

NEWCSRDIR=$($GETCACONF  -k new_certs_dir)
CERTDIR=$($GETCACONF -k certs)

PINARGS=
handle_pin SO_PIN --pin || handle_pin OLD_SO_PIN --pin

#set -x
#TOOO read key-usage from openssl.conf
pkcs15-init --reader $READER_ID --delete-objects privkey,pubkey,cert --id $CERTID --generate-key $CA_ALGO/$CA_CARD_BITSIZE --auth-id $READER_SO_AUTH_ID --verify $PINARGS --label "$CA_LABEL" --key-usage sign,decrypt,nonRepudiation


# generate CSR
echo "Generate CSR for $CA_FILEBASENAME"
RFC7512_URI="pkcs11:id=%$((CERTID / 16))$((CERTID % 16))"
if [ -n "$PIN" ]; then
	RFC7512_URI="$RFC7512_URI?pin-value=$PIN"
fi
openssl req -config $CAUTL_GENERATED_FILE -engine pkcs11 -keyform engine -new -key $RFC7512_URI -nodes -sha256 -out $NEWCSRDIR/$CA_FILEBASENAME.pem -subj "/C=$CA_COUNTRY/O=$CA_ORG/OU=$CA_OU/$CA_LABEL"
if [ ! -f "$NEWCSRDIR/$CA_FILEBASENAME.pem" ]; then
	echo "Can't read CSR" 1>&2
	exit 1
fi

# sign
echo "Sign CSR for $CA_FILEBASENAME"
SIGN_OPTIONS=
if [ "$cert_type" == "host" ]; then
	SIGN_OPTIONS="$SIGN_OPTIONS --host $CA_FILEBASENAME"
fi
sv_call_subverb sign $SIGN_OPTIONS $CA_FILEBASENAME.pem
if [ ! -f "$CERTDIR/$CA_FILEBASENAME.pem" ]; then
	echo "Sign certificate failed" 1>&2
	exit 1
fi

# upload cert
echo "Upload certificate for $CA_FILEBASENAME"
sv_call_subverb convert --in $CERTDIR/$CA_FILEBASENAME.pem --out $CERTDIR/$CA_FILEBASENAME.der
pkcs11-tool --slot-index $READER_ID --login --id $CERTID --write-object $CERTDIR/$CA_FILEBASENAME.der --type cert 


