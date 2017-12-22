CAUTL_GROUP=${CAUTL_GROUP:-default}
CA_QUIET=${CA_QUIET:-0}

SV_OPTION[file]=CA_FILE
SV_SHORT_OPTION[f]=CA_FILE

SV_OPTION[group]=CAUTL_GROUP
SV_SHORT_OPTION[g]=CAUTL_GROUP

SV_OPTION[keep-files]=:CA_KEEP

SV_OPTION[quiet]=:CA_QUIET
SV_SHORT_OPTION[q]=:CA_QUIET

sv_parse_options "$@"

if [ -n "$CA_KEEP" -o -n "$CA_FILE" ]; then
	export SV_DEBUG="$SV_DEBUG,keep_cnf"
fi

generate_configfile ${CAUTL_GROUP}

if [ -n "$CA_FILE" ]; then
	mv "$CAUTL_GENERATED_FILE" "$CA_FILE"
	CAUTL_GENERATED_FILE="$CA_FILE"
fi

if [ "$CA_QUIET" -eq 0 ]; then
	echo "Generated: $CAUTL_GENERATED_FILE"
fi
