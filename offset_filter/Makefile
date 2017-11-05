# Type "make tar" to bundles up matlab package into a tar-ball.
# $Id

TAR_INCLUDEFILES = $(wildcard *.m) $(wildcard *.jpg) $(wildcard private/*.m) \
		AUTHORS COPYING VERSION README ChangeLog
VERSION := $(shell less VERSION)

tar: $(TAR_INCLUDEFILES)
#	@echo VERSION=$(VERSION)
#	mkdir offset_filter-$(VERSION)
#	cp -r $(TAR_INCLUDEFILES) offset_filter-$(VERSION)
	tar cvjf offset_filter-$(VERSION).tar.bz2 -C .. \
		--exclude-from tar_exclude  offset_filter
#	rm -fr offset_filter-$(VERSION)

