SV_HELP="Generate current openssl configuraiton file"
SV_GROUP=utils
CA_QUIET=${CA_QUIET:-0}

SV_OPTION[file]=CA_FILE
SV_SHORT_OPTION[f]=CA_FILE
SV_OPTION_HELP[CA_FILE]="specify a filename for the generated data"

SV_OPTION[keep-files]=:CA_KEEP
SV_OPTION_HELP[CA_KEEP]="By default, the generated file will be removed, when the application exits. With this option, the file will be left."

SV_OPTION[quiet]=:CA_QUIET
SV_SHORT_OPTION[q]=:CA_QUIET
SV_OPTION_HELP[CA_QUIET]="Suppress normal output"

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
