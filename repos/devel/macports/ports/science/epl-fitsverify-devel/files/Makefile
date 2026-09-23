FITSVERIFY = fitsverify
INCLUDES = fverify.h
SOURCES = ftverify.c fvrf_data.c fvrf_file.c fvrf_head.c \
	fvrf_key.c fvrf_misc.c

all:
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $(FITSVERIFY) $(SOURCES) $(LIBS)

install:
	install -m 755 $(FITSVERIFY) $(DESTDIR)$(BINDIR)

clean:
	rm -f $(FITSVERIFY) *.o
