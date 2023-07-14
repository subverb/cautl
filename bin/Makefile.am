dist_bin_SCRIPTS=openssl_getconf

install-exec-hook:
	@mkdir -p $(DESTDIR)$(bindir)
	(cd $(DESTDIR)$(bindir); $(LN_S) subverb cautl)
