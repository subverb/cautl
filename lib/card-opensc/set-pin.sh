
SV_OPTION[current]="SP_CURRENT"
SV_OPTION_HELP[SP_CURRENT]="Pass the currently set pin"

SV_OPTION[pin]="SP_PIN"
SV_OPTION_HELP[SP_PIN]="Specify a pin to set"

SV_OPTION[puk]="SP_PUK"
SV_OPTION_HELP[SP_PUK]="Specify a puk to set"

SV_OPTION[type]="SP_TYPE"
SV_OPTION_HELP[SP_TYPE]="Specify the type of pin to set (either by id or user|so)"

SV_OPTION[conffile]="SP_CONF"
SV_OPTION_HELP[SP_CONF]="Token configuration file"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

local PINARGS
handle_pin SP_CURRENT --pin
handle_pin SP_PIN --new-pin
handle_pin SP_PUK --puk

case "$SP_TYPE" in
	user)
		SP_TYPE=$READER_DEFAULT_AUTH_ID
		;;
	so)
		SP_TYPE=$READER_SO_AUTH_ID
		PINARGS="$PINARGS --login-type so"
		handle_pin SP_CURRENT --so-pin
		;;
esac

pkcs11-tool --slot-index $READER_ID --id $SP_TYPE --$READER_PIN_METHOD-pin $PINARGS --login
