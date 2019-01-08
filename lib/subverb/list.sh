SV_HELP="list all known certificates"
SV_GROUP=CA_handling
ls $($GETCACONF -k certs)
