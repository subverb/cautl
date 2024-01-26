pkcs11-tool -O 2>/dev/null | sed -ne '/subject:/{s/.*CN=//;p};' | sort | uniq
