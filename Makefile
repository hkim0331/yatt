#isc
PREFIX=/edu
BIN=${PREFIX}/bin
LIB=${PREFIX}/lib/yatt

#osx
PREFIX=${HOME}
BIN=${PREFIX}/bin
LIB=${PREFIX}/Library/yatt

isc: yatt.isc yatt.rb README lib/yatt.doc
	if [ ! -d /edu/lib/yatt ]; then \
		mkdir /edu/lib/yatt; \
	fi
	cp README /edu/lib/yatt.README
	cp lib/yatt.doc /edu/lib/yatt.doc
	cp lib/yatt.gif /edu/lib
	install -m 0755 yatt.rb /edu/bin/yatt.rb
	install -m 0755 yatt.isc /edu/bin/yatt

osx: yatt.osx yatt.rb README lib/yatt.doc
	if [ ! -d /Users/hkim/Library/yatt ]; then \
		mkdir /Users/hkim/Library/yatt; \
	fi
	cp README /Users/hkim/Library/yatt.README
	cp lib/yatt.doc /Users/hkim/Library/yatt.doc
	cp lib/yatt.gif /Users/hkim/Library/
	install -m 0755 yatt.rb /Users/hkim/bin/yatt.rb
	install -m 0755 yatt.osx /Users/hkim/bin/yatt

linux: yatt.linux yatt.rb README lib/yatt.doc
	if [ ! -d /Users/hkim/Library/yatt ]; then \
		mkdir /Users/hkim/Library/yatt; \
	fi
	cp README /Users/hkim/Library/yatt.README
	cp lib/yatt.doc /Users/hkim/Library/yatt.doc
	cp lib/yatt.gif /Users/hkim/Library/
	install -m 0755 yatt.rb /Users/hkim/bin/yatt.rb
	install -m 0755 yatt.isc /Users/hkim/bin/yatt

server: yatt_server.rb yatt_server
	install -m 0755 yatt_server.rb /usr/local/bin
	install -m 0755 yatt_server /usr/local/bin

clean:
	${RM} *~ .\#*
