DIR=$($GETCACONF -k certs)
REFDATE=$(date -d"+${SV_DAYS}days" +"%s")
for i in $(ls $DIR/*.pem); do
	CERTDATE=$(openssl x509 -enddate -noout -in $i | sed -e 's/.*=\s*//;s/\s*$//')
	CERTREL=$(date +"%s" -d"${CERTDATE}")
	if [ $CERTREL -lt $REFDATE ]; then
		echo "$i: $CERTDATE"
	fi
done

