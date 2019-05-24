SV_HELP="Initialize the local certificate store"
SV_GROUP=Housekeeping
SV_OPTION[root-ca]=":INIT_ROOT_CA"
SV_HANDLE_HELP=sourced

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi


for i in new_certs_dir certs crl_dir; do
	DIR=$($GETCACONF -k "$i")
	test "$DIR" || continue
	if [ ! -d "$DIR" ]; then
		echo creating $i: $DIR
		mkdir -p $DIR
	fi
done

for i in database serial crlnumber certificate private_key RANDFILE crl; do
	FILE=$($GETCACONF -k "$i")
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

check_or_subverb() {
	FILE=$($GETCACONF -k $1)
	echo "Checking $FILE"
	if [ ! -f "$FILE" ]; then
		echo "Calling $2"
		sv_call_subverb $2
	fi
}

if [ "$INIT_ROOT_CA" == "1" ]; then
	check_or_subverb private_key gencsr
	check_or_subverb certificate selfsign
	check_or_subverb crl gencrl
fi

echo Done
