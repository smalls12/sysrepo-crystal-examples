.PHONY: all
all:
	@echo Nothing to do

build:
	# build libyang
	git clone --depth=1 https://github.com/CESNET/libyang.git
	mkdir -p libyang/build; \
	cd libyang/build; \
	cmake ..; \
	make; \
	sudo make install

	# build sysrepo
	git clone --depth=1 https://github.com/sysrepo/sysrepo.git
	mkdir -p sysrepo/build; \
	cd sysrepo/build; \
	cmake ..; \
	make; \
	sudo make install