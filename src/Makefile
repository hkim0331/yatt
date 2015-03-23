# VERSION: 0.31.1

BIN=${HOME}/bin
YATT_BIN=/usr/local/yatt/bin

all:
	@echo "'make osx' to install on osx(develop)."
	@echo "'make isc' to install on isc."
	@echo "'make linux' to install on general linuxen."
	@echo "'make monitor' to install yatt monitor under ${YATT_BIN}."

isc: yatt.rb
	install -m 0755 yatt.rb /edu/bin/yatt
	./chsb --sb /edu/bin/ruby /edu/bin/yatt

osx: yatt.rb
	mkdir -p ${BIN}
	install -m 0755 yatt.rb ${BIN}/yatt

linux: yatt.rb
	mkdir -p ${BIN}
	install -m 0755 yatt.rb ${BIN}/yatt

server: monitor gems

monitor: yatt_monitor.rb yatt_monitor
	mkdir -p ${YATT_BIN}
	install -m 0755 yatt_monitor yatt_monitor.rb ${YATT_BIN}
	@echo 'do not forget to open monitor port(default 23002/tcp).'
	install -m 0755 yatt_monitor.service /etc/init.d/yatt_monitor
	update-rc.d yatt_monitor default

gems:
	gem install sequel mysql2

clean:
	${RM} *~ .\#* *.bak
