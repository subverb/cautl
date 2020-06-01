regex='<<([a-zA-Z_][a-zA-Z_0-9]*)>>'
includere='^<<include ([a-zA-Z_0-9.]+)>>'
setre='^<<([a-zA-Z_][a-zA-Z_0-9]+)=([^>]*)>>'
spaceonlyre='^\s*$'
ifre='(.*)<<if ([^>][^>]*)>>(.*)'
elsere='(.*)<<else>>(.*)'
endre='(.*)<<end>>(.*)'

_parse_line() {
	declare line="$1"
	if [[ "$line" =~ $spaceonlyre ]]; then
		return
	fi
	if [[ "$line" =~ $endre ]]; then
		_parse_line "${BASH_REMATCH[1]}"
		#echo "end IFSTATE: ${IFSTATE[*]}"
		if [ ${#IFSTATE[*]} -lt 2 ]; then
			echo "<<end>> without if!" 1>&2
			exit 1
		fi
		unset IFSTATE[-1]
		_parse_line "${BASH_REMATCH[2]}"
		return
	fi
	if [[ "$line" =~ $elsere ]]; then
		_parse_line "${BASH_REMATCH[1]}"
		# invert current ifstate
		if [ ${#IFSTATE[*]} -lt 2 ]; then
			echo "<<else>> without if!" 1>&2
			exit 1
		fi
		#echo "invert IFSTATE: ${IFSTATE[*]}"
		IFSTATE[-1]="$((${IFSTATE[-2]} * ! ${IFSTATE[-1]}))"
		#echo "invres IFSTATE: ${IFSTATE[*]}"
		_parse_line "${BASH_REMATCH[2]}"
		return
	fi
	if [[ "$line" =~ $ifre ]]; then
		declare preline="${BASH_REMATCH[1]}"
		declare testexp="${BASH_REMATCH[2]}"
		declare postline="${BASH_REMATCH[3]}"
		declare newifstate=${IFSTATE[-1]}
		_parse_line "$preline"
		if [[ "$newifstate" -gt 0 ]]; then
			eval "$testexp"
			newifstate=$((!$?))
		fi
		#echo "new(${#IFSTATE[*]}) IFSTATE: ${IFSTATE[*]} ($newifstate)"
		IFSTATE[${#IFSTATE[*]}]=$newifstate
		#echo "res(${#IFSTATE[*]}) IFSTATE: ${IFSTATE[*]}"
		_parse_line "$postline"
		return
	fi
	if [[ "${IFSTATE[-1]}" -lt 1 ]]; then
		return
	fi
	if [[ "$line" =~ $includere ]]; then
		FILE=${BASH_REMATCH[1]}
		if [ "${FILE:0:1}" != "/" ]; then
			FILE="$BASEDIR/$FILE"
		fi
		parse_template < "$FILE"
		return
	fi
	while [[ "$line" =~ $setre ]]; do
		param="${BASH_REMATCH[1]}"
		value="${BASH_REMATCH[2]}"
		eval "$param=\"$value\""
		line="${line//${BASH_REMATCH[0]}/}"
	done
	while [[ "$line" =~ $regex ]]; do
		param="${BASH_REMATCH[1]}"
		line="${line//${BASH_REMATCH[0]}/${!param}}"
	done
	echo "$line"
}

parse_template() {
	BASEDIR=${1:-.}
	declare -a IFSTATE=(1)
	while read line; do
		_parse_line "$line"
	done
}

template2tempfile() {
	filename=$(mktemp --tmpdir cautl_XXXXXXXX.cnf)
	echo "$SV_DEBUG" | grep -q "keep_cnf" || trap_add "rm $filename" EXIT
	parse_template "$@" >$filename
	declare -g CAUTL_GENERATED_FILE=$filename
}

generate_configfile() {
	OIDs=
	for oid_label in "${!ADD_OID[@]}"; do
		oid="${ADD_OID[$oid_label]}"
		if [ "$(openssl asn1parse -genstr "OID:$oid"  | sed -e 's/.*://')" == "$oid" ]; then
			printf -v OIDs "$OIDs\n$oid_label\t= $oid"
		fi
	done
	file=${1:-default}.cnf
	DATADIR=$(sv_default_dir pkgdata)
	template2tempfile $DATADIR < $DATADIR/${file}
}
