AC_INIT(cautl, 1.0.3, benjamin@micronet24.de)
AM_INIT_AUTOMAKE([foreign])
AC_PROG_LN_S
AC_PROG_SED
AC_PROG_GREP
PKG_PROG_PKG_CONFIG

# ARG_WITH_SET(option, default, help)
# -----------------------------------
# Create a --with-$1 option with helptext, set a variable $1 to $withval/default
AC_DEFUN([ARG_WITH_SET],
        [AC_ARG_WITH(
                [$1],
                AS_HELP_STRING([--with-$1=arg], [$3 (default: $2).]),
                patsubst([$1], [-], [_])="$withval",
                patsubst([$1], [-], [_])=$2
        )]
)

if test -n "$PKG_CONFIG"; then
	systemdsystemunitdir_default=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)
fi
ARG_WITH_SET([systemdsystemunitdir], [$systemdsystemunitdir_default], [directory for systemd service files])
AC_SUBST(systemdsystemunitdir)

MANSUBVERBS=$(basename -s .sh $(${GREP} -e 'subverb/' lib/Makefile.am | ${SED} -e 's,\\$,,') | ${SED} -e 's,^,cautl-,;s,$,.1,' | tr '\n' ' ')
AC_SUBST(MANSUBVERBS)

AC_CONFIG_FILES([Makefile etc/Makefile lib/Makefile share/Makefile bin/Makefile])
AC_OUTPUT
