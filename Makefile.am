SUBDIRS=etc lib share bin

man1_MANS=cautl.1 $(MANSUBVERBS)

cautl.1: cautl
	./cautl help --man > $@

cautl-%.1: lib/subverb/%.sh
	./cautl help $* --man > $@
