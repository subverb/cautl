GETCONF="openssl_getconf -f $OPENSSL_CONF" 
DEFAULTCA=$($GETCONF -k default_ca)
GETCONF="$GETCONF -s $DEFAULTCA"

for i in new_certs_dir certs crl_dir; do
	DIR=$($GETCONF -k "$i")
	test "$DIR" || continue
	if [ ! -d "$DIR" ]; then
		echo creating $i: $DIR
		mkdir -p $DIR
	fi
done

for i in database serial crlnumber certificate private_key RANDFILE crl; do
	FILE=$($GETCONF -k "$i")
	test "$FILE" || continue
	DIR=$(dirname $FILE)

	if [ ! -d "$DIR" ]; then
		echo creating dir for $i: $DIR
		mkdir -p $DIR
		if [ "$i" == "private_key" -o "$i" == "RANDFILE" ]; then
			chmod 0700 $DIR
		fi
	fi

	if [ ! -f "$FILE" ]; then
		case "$i" in
			serial)
				openssl rand -hex 16 > $FILE
				;;
			crlnumber)
				echo 1001 > $FILE
				;;
			database)
				touch $FILE
				;;
		esac
	fi
done

test -d ~/.cautl && touch ~/.cautl/cautl.conf

echo Done
