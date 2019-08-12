echo "Card certificates: "
pkcs11-tool -O | sed -ne '/label:/{s/\s*label:\s*//;p}'
