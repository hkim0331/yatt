# VERSION: 0.15

BIN=${HOME}/bin
YATT=/usr/local/yatt

all:
	@echo "'make osx' to install on osx(develop)."
	@echo "'make isc' to install on isc."
	@echo "'make linux' to install on general linuxen."
	@echo "'make monitor' to install yatt monitor under ${YATT}."

isc: yatt.isc yatt.rb
	install -m 0755 yatt.rb /edu/bin/yatt.rb
	install -m 0755 yatt.isc /edu/bin/yatt

osx: yatt.osx yatt.rb
	mkdir -p ${BIN}
	install -m 0755 yatt.rb ${BIN}/yatt.rb
	install -m 0755 yatt.osx ${BIN}/yatt

linux: yatt.linux yatt.rb
	mkdir -p ${BIN}
	install -m 0755 yatt.rb ${BIN}/yatt.rb
	install -m 0755 yatt.linux ${BIN}/yatt

server: yatt_monitor.rb yatt_monitor
	install -m 0755 yatt_monitor yatt_monitor.rb ${YATT}

clean:
	${RM} *~ .\#* *.bak
