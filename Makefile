#isc
PREFIX=/edu
BIN=${PREFIX}/bin
LIB=${PREFIX}/lib/yatt

#osx
#PREFIX=${HOME}
#BIN=${PREFIX}/bin
#LIB=${PREFIX}/Library/yatt

isc: yatt.isc yatt.rb README lib/yatt.doc
	if [ ! -d ${LIB} ]; then \
		mkdir ${LIB}; \
	fi
	cp README ${LIB}/yatt.README
	cp lib/yatt.doc ${LIB}/yatt.doc
	cp lib/yatt.gif ${LIB}
	install -m 0755 yatt.rb ${BIN}
	install -m 0755 yatt.isc ${BIN}/yatt

server: yatt_server.rb yatt_server
	install -m 0755 yatt_server.rb /usr/local/bin
	install -m 0755 yatt_server /usr/local/bin

clean:
	${RM} *~ .\#*
