# VERSION: 0.17.2

BIN=${HOME}/bin
YATT_BIN=/usr/local/yatt/bin

all:
	@echo "'make osx' to install on osx(develop)."
	@echo "'make isc' to install on isc."
	@echo "'make linux' to install on general linuxen."
	@echo "'make monitor' to install yatt monitor under ${YATT_BIN}."

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

server: monitor

monitor: yatt_monitor.rb yatt_monitor yatt_at.sh
	install -m 0755 yatt_monitor yatt_monitor.rb ${YATT_BIN}
	install -m 0755 yatt_at.sh ${YATT_BIN}

clean:
	${RM} *~ .\#* *.bak
