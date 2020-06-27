AC_INIT(cautl, 0.01, benjamin@micronet24.de)
AM_INIT_AUTOMAKE([foreign])
AC_PROG_LN_S
AC_PROG_SED
AC_PROG_GREP
PKG_PROG_PKG_CONFIG

if test -n "$PKG_CONFIG"; then
	systemdsystemunitdir_default=$($PKG_CONFIG --variable=systemdsystemunitdir systemd)
fi
ARG_WITH_SET([systemdsystemunitdir], [$systemdsystemunitdir_default], [directory for systemd service files])
AC_SUBST(systemdsystemunitdir)

MANSUBVERBS=$(basename -s .sh $(${GREP} -e 'subverb/' lib/Makefile.am | ${SED} -e 's,\\$,,') | ${SED} -e 's,^,cautl-,;s,$,.1,' | tr '\n' ' ')
AC_SUBST(MANSUBVERBS)

AC_CONFIG_FILES([Makefile etc/Makefile lib/Makefile share/Makefile bin/Makefile])
AC_OUTPUT
