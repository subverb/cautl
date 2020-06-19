SV_OPTION[kdc-guid]="KDC_GUID"
SV_OPTION_HELP[KDC_GUID]="the hexadecimal encoded GUID of the server"

sv_parse_options "$@"

if [ -z "$KDC_GUID" ]; then
	echo "Please specify the GUID of your kdc using --kdc-guid" 1>&2
	exit 1
fi

# Ordinarily, certificates must have this oid as an enhanced key usage in order for Windows to allow them to be used to identify a domain controller
ADD_OID[msKDC]=1.3.6.1.5.2.3.5
# Identifies the AD GUID
ADD_OID[msADGUID]=1.3.6.1.4.1.311.25.1

EXT_KEY_USAGES[serverAuth]=1
EXT_KEY_USAGES[msKDC]=1

SANS[${#SANS}]="otherName.0=msADGUID;FORMAT:HEX,OCTETSTRING:$KDC_GUID"
