.PHONY: all clean

CFILES=$(wildcard *.c)
OFILES=$(patsubst %.c,%.o,$(CFILES))

LIBPNG=libpng-1.6.43

all: runtime.a

$(LIBPNG)/configure:
	curl -L https://download.sourceforge.net/libpng/$(LIBPNG).tar.xz | tar -xJ

$(LIBPNG)/target/include/png.h: $(LIBPNG)/configure
	(cd libpng-1.6.43 && LDFLAGS="-arch x86_64" CPPFLAGS="-arch x86_64" ./configure --prefix $(PWD)/$(LIBPNG)/target)
	$(MAKE) -C $(LIBPNG) install

%.o: %.c $(LIBPNG)/target/include/png.h
	$(CC) -arch x86_64 -I$(LIBPNG)/target/include -Og -Werror -Wall -Wpedantic -c -o $@ -- $<

runtime.a: $(OFILES) $(LIBPNG)/target/lib/libpng16.a
	cp $(LIBPNG)/target/lib/libpng16.a $@
	ar rcs $@ $(OFILES)

clean:
	rm -f $(OFILES) runtime.a
ifneq (,$(wildcard $(LIBPNG)/Makefile))
	$(MAKE) -C $(LIBPNG) clean
endif

fullclean:
	rm -rf $(LIBPNG)
	@$(MAKE) clean
