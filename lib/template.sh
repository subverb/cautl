regex='<<([a-zA-Z_][a-zA-Z_0-9]*)>>'
includere='^<<include ([a-zA-Z_0-9.]+)>>'
setre='^<<([a-zA-Z_][a-zA-Z_0-9]+)=([^>]*)>>'

trap_add() {
	cmd=$1
	shift
	for sig in $@; do
		oldtrapcmd="$(trap -p $sig | sed -e "s/^trap -- '//;s/' EXIT//")"
		if [ -n "$oldtrapcmd" ]; then oldtrapcmd="$oldtrapcmd; "; fi
		trap "$oldtrapcmd $cmd" $sig
	done
}
declare -f -t trap_add

parse_template() {
	while read line; do
		if [[ "$line" =~ $includere ]]; then
			parse_template < "${BASH_REMATCH[1]}"
			continue
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
	done
}

template2tempfile() {
	filename=$(mktemp --tmpdir cautl_XXXXXXXX.cnf)
	echo "$SV_DEBUG" | grep -q "keep_cnf" || trap_add "rm $filename" EXIT
	parse_template >$filename
	echo $filename
}
