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


