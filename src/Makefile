# VERSION: 0.22.1

BIN=${HOME}/bin
YATT_BIN=/usr/local/yatt/bin

all:
	@echo "'make osx' to install on osx(develop)."
	@echo "'make isc' to install on isc."
	@echo "'make linux' to install on general linuxen."
	@echo "'make monitor' to install yatt monitor under ${YATT_BIN}."

isc: yatt.rb
	install -m 0755 yatt.rb /edu/bin/yatt
	/home/t/hkimura/bin/chsb --sb /edu/bin/ruby /edu/bin/yatt

osx: yatt.rb
	mkdir -p ${BIN}
	install -m 0755 yatt.rb ${BIN}/yatt

linux: yatt.rb
	mkdir -p ${BIN}
	install -m 0755 yatt.rb ${BIN}/yatt

# isc: yatt.isc yatt.rb
# 	install -m 0755 yatt.rb /edu/bin/yatt.rb
# 	install -m 0755 yatt.$@ /edu/bin/yatt

# osx: yatt.osx yatt.rb
# 	mkdir -p ${BIN}
# 	install -m 0755 yatt.rb ${BIN}/yatt.rb
# 	install -m 0755 yatt.$@ ${BIN}/yatt

# linux: yatt.linux yatt.rb
# 	mkdir -p ${BIN}
# 	install -m 0755 yatt.rb ${BIN}/yatt.rb
# 	install -m 0755 yatt.$@ ${BIN}/yatt


server: monitor

monitor: yatt_monitor.rb yatt_monitor
	install -m 0755 yatt_monitor yatt_monitor.rb ${YATT_BIN}

clean:
	${RM} *~ .\#* *.bak
