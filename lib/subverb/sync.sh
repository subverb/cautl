SV_HELP="syncronize certificates with external folder"
SV_GROUP=utils
SV_HANDLE_HELP=sourced

sync_in=0
SV_OPTION[in]=":sync_in"
SV_OPTION_HELP[sync_in]="syncronize from external folder to cautl"

sync_out=0
SV_OPTION[out]=":sync_out"
SV_OPTION_HELP[sync_out]="syncronize from cautl to external folder"

SV_OPTION[dir]="CA_SYNC_DIRECTORY"
SV_OPTION_HELP[CA_SYNC_DIRECTORY]="external foldert to sync with"

sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

if [ -z "${CA_SYNC_DIRECTORY}" ]; then
	echo "Please set CA_SYNC_DIRECTORY in configuration option to enable syncronisation" 1>&2
	return 0
fi
if [ $sync_in -eq $sync_out ]; then
	echo "Please pass exactly one of --in or --out" 1>&2
	return 1
fi

local -A sync_map=(
		[new_certs_dir]=pem
		[certs]=pem
		[private_key]="conf p12"
)

if [ $sync_in -eq 1 ]; then
	for s in "${!sync_map[@]}"; do
		local l=$($GETCACONF -k $s)
		if [ -f "$l" ]; then l=$(dirname "$l"); fi
		for ext in ${sync_map[$s]}; do
			cp -vu "${CA_SYNC_DIRECTORY}/$s/"*.$ext "$l"
		done
	done
else # $sync_out -eq 1
	for s in "${!sync_map[@]}"; do
		local l=$($GETCACONF -k $s)
		if [ -f "$l" ]; then l=$(dirname "$l"); fi
		mkdir -p "${CA_SYNC_DIRECTORY}/$s"
		for ext in ${sync_map[$s]}; do
			cp -vu "$l"/*.$ext "${CA_SYNC_DIRECTORY}/$s/"
		done
	done
fi
