READER=$(opensc-tool -l | grep -Pe "^\d+\s+Yes" | sed -ne '/^[0-9]\+/{s/\([0-9]\+\) *\(Yes\|No\) *\([^(]*\)\( ([0-9A-F]*)\)\?\( [0-9A-F]\{2\}\)\{2\}/\1 \3/;s/ /_/g;s/_/ /;p}' | head -n 1 )
if [ -z "$READER" ]; then
	croak "No supported reader found!"
fi

READER_ID=$(echo "$READER" | sed -e 's/ .*//;')
READER_NAME=$(echo "$READER" | sed -e 's/.* //;')

# key-ID on the reader to change
READER_DEFAULT_ID=1

# wether readers supports card-erase (pkcs15 or openpgp)
READER_SUPPORT_ERASE=pkcs15

# method to support public keys, supported by reader (pkcs11 or pkcs15)
READER_SUPPORT_PUBKEY=pkcs15

# might be init or change. 
READER_PIN_METHOD=init

# cautl group to use, when generating csr for the card
READER_GROUPTYPE="client"

# define the slots, the certificate should be copied to
declare -ga READER_CERT_TARGET

sv_backend --group "" --backend readerconfig --optional $READER_NAME

# TODO evaluate PIN and SOPIN-length, if not set by readerconfig

handle_pin() {
	local pin=$1
	local -n pinref=$pin
	local arg=$2
	if [ -n "$pinref" ]; then
		export G_$pin=$pinref
		PINARGS="$PINARGS $arg ENV:G_$pin"
	fi
}

CARD_BACKEND="card-opensc"
