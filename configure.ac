AC_INIT(cautl, 1.0.1, benjamin@micronet24.de)
AM_INIT_AUTOMAKE([foreign])
AC_PROG_LN_S
AC_PROG_SED
AC_PROG_GREP

MANSUBVERBS=$(basename -s .sh $(${GREP} -e 'subverb/' lib/Makefile.am | ${SED} -e 's,\\$,,') | ${SED} -e 's,^,cautl-,;s,$,.1,' | tr '\n' ' ')
AC_SUBST(MANSUBVERBS)

AC_CONFIG_FILES([Makefile etc/Makefile lib/Makefile share/Makefile bin/Makefile])
AC_OUTPUT
