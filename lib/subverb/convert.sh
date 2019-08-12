#!cautl

SV_GROUP=utils
SV_HELP="import, export or convert certificate files"
SV_HANDLE_HELP=sourced

options_cert_name_type

SV_OPTION[in]="CA_INFILE"
SV_SHORT_OPTION[i]="CA_INFILE"
SV_OPTION_HELP[CA_INFILE]="filename to read from ('-' for stdin)"

SV_OPTION[from]="CA_FROM"
SV_SHORT_OPTION[F]="CA_FROM"
SV_OPTION_HELP[CA_FROM]="define file-format of input file"

SV_OPTION[out]="CA_OUTFILE"
SV_SHORT_OPTION[o]="CA_OUTFILE"
SV_OPTION_HELP[CA_OUTFILE]="filename to write to ('-' for stdout)"

SV_OPTION[to]="CA_TO"
SV_SHORT_OPTION[T]="CA_TO"
SV_OPTION_HELP[CA_TO]="file-format for written certificate file"

CA_LIST=0
SV_OPTION[list]=":CA_LIST"
SV_SHORT_OPTION[l]=":CA_LIST"
SV_OPTION_HELP[CA_LIST]="list supported filetypes for in- and output."

CA_FORCE=0
SV_OPTION[force]=":CA_FORCE"
SV_OPTION_HELP[CA_FORCE]="overwrite existing certificates."

SV_OPTION[passin]="CA_PASSIN"
SV_OPTION_HELP[CA_PASSIN]="provide password for input certificate (prefix with file: or env: for read from file or environment)"

SV_OPTION[passout]="CA_PASSOUT"
SV_OPTION_HELP[CA_PASSOUT]="provide password for output certificate"
sv_parse_options "$@"

if [ "$1" == "_help_source_" ]; then
	return 0
fi

if [ $CA_LIST -gt 0 ]; then
	cat >&2 <<"CA_LIST"
Supported input formats:

	pem der

Supported output formats:

	pem der

CA_LIST
	return 0
fi

_guess_certtype() {
	case "$1" in
		*.pem|*.csr)		echo pem;;
		*.der|*.crt|*.cer)	echo der;;
		*)			return 1;;
	esac
	return 0
}

if [ -z "$CA_OUTFILE" -a -n "$CA_TO" ]; then
	if [ -n "$CA_INFILE" ]; then
		CA_OUTFILE="$CA_INFILE"
	elif test_cert_name_type; then
		CA_OUTFILE="$(cert_name2file)"
	else
		echo "No certificate to convert found"
	fi
	CA_OUTFILE=${CA_OUTFILE%.*}.$CA_TO
fi

CA_LOCAL_FILE=
if [ -n "$CA_INFILE" ]; then
	if test_cert_name_type; then
		CA_LOCAL_FILE=$(cert_name2file)
	elif [ -n "$CA_OUTFILE" ]; then
		CA_LOCAL_FILE=$(mktemp --dry-run --tmpdir cautl_XXXXXXXX.pem)
		trap_add "rm ${CA_LOCAL_FILE}" EXIT
	elif CERT_NAME=$(basename "$CA_INFILE") test_cert_name_type; then
		CERT_NAME=$(basename "$CA_INFILE")
		CA_LOCAL_FILE=$(cert_name2file)
	else
		echo "Can't import file ${CERT_TYPE}/${CERT_NAME:-$(basename "$CA_INFILE")}"
	fi
	if [ -e "${CA_LOCAL_FILE}" -a ${CA_FORCE} -le 0 ]; then
		echo "certificate already exists - refusing overwrite"
		exit 1
	fi
	CA_FROM=${CA_FROM:-$(_guess_certtype "$CA_INFILE" || croak "Unknown certificate type!")}
	case "${CA_FROM}" in
		pem)	cp "$CA_INFILE" "$CA_LOCAL_FILE";;
		der)	openssl x509 -inform ${CA_FROM} -in "$CA_INFILE" -out "$CA_LOCAL_FILE";;
		*)
			echo "Unknown certificate type '${CA_FROM}'!" >&2
			exit 1
			;;
	esac
fi

if [ -n "$CA_OUTFILE" ]; then
	if [ -z "$CA_LOCAL_FILE" ]; then
		if test_cert_name_type; then
			CA_LOCAL_FILE=$(cert_name2file)
		else
			echo "No certificate to export" >&2
			exit 1
		fi
	fi
	if [ ! -e "$CA_LOCAL_FILE" ]; then
		echo "Certificate to export '$CA_LOCAL_FILE'" >&2
		exit 1
	fi
	if [ -n "$CA_PASSIN" ]; then
		CA_PASSIN_ARG="-passin $CA_PASSIN"
	else
		CA_PASSIN_ARG="-passin file:${CA_LOCAL_FILE}.pwd"
	fi
	if [ -n "$CA_PASSOUT" ]; then
		CA_PASSOUT_ARG="-passout $CA_PASSOUT"
	fi
	CA_TO="${CA_TO:-$(_guess_certtype "$CA_OUTFILE" || croak "Unknown certificate type!")}"
	case "${CA_TO}" in
		pem)	cp "$CA_LOCAL_FILE" "$CA_OUTFILE";;
		der)	openssl x509 -outform ${CA_TO} -in "$CA_LOCAL_FILE" -out "$CA_OUTFILE";;
		nopwd.pem) 
			if [ "$CERT_TYPE" != "private" ]; then
				echo "only private items should be password protected"
				exit 1
			fi
			openssl rsa -outform pem -in "$CA_LOCAL_FILE" ${CA_PASSIN_ARG} -out "$CA_OUTFILE"
			;;
		*)
			echo "Unknown certificate type '${CA_TO:-${CA_OUTFILE}}'!" >&2
			exit 1
			;;
	esac
fi
