DIR=$($GETCACONF -k certs)
REFDATE=$(date -d"+${SV_DAYS}days" +"%s")
for i in $(ls $DIR/*.pem); do
	CERTDATE=$(openssl x509 -enddate -noout -in $i | sed -e 's/.*=\s*//;s/\s*$//')
	CERTREL=$(date +"%s" -d"${CERTDATE}")
	SANOFFSET=$(sed -ne '/--- *BEGIN/,/--- *END/p' $i | openssl asn1parse -inform PEM | grep "X509v3 Subject Alternative Name" -A 1 | sed -e 's/:.*//' | tail -n 1)
	if [ -n "$SANOFFSET" ]; then
		SAN=$(sed -ne '/--- *BEGIN/,/--- *END/p' $i | openssl asn1parse -inform PEM -strparse $SANOFFSET | sed -ne '/UTF8STRING/{s/.*UTF8STRING\s*://;p}')
	fi
	SANOFFSET=$(sed -ne '/--- *BEGIN/,/--- *END/p' $i | openssl asn1parse -inform PEM | grep -e "1.3.6.1.4.1.43931.3.2" -e "cautlCardID" -A 1 | sed -e 's/:.*//' | tail -n 1)
	if [ -n "$SANOFFSET" ]; then
		SAN="${SAN}#$(sed -ne '/--- *BEGIN/,/--- *END/p' $i | openssl asn1parse -inform PEM -strparse $SANOFFSET | sed -ne '/UTF8STRING/{s/.*UTF8STRING\s*://;p}')"
	fi
	if [ $CERTREL -lt $REFDATE ]; then
		echo "$CERTREL| $CERTDATE: $i($SAN)"
	fi
done | sort -n | sed -e 's/.*| //;s,: .*/,: ,'

