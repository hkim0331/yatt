# VERSION: 0.50

BIN=${HOME}/bin
MONITOR_BIN=/srv/yatt/bin
MONITOR_LOG=/srv/yatt/log

all:
	@echo "'make osx' to install on osx(develop)."
	@echo "'make isc' to install on isc."
	@echo "'make linux' to install on general linuxen."
	@echo "'make monitor' to install yatt monitor under ${YATT_MONITOR}."

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

monitor: yatt_monitor.rb yatt_monitor.service
	mkdir -p ${MONITOR_BIN} ${MONITOR_LOG}
	install -m 0755 yatt_monitor.rb ${MONITOR_BIN}
	@echo 'do not forget to open monitor port(default 23002/tcp).'
# ここ。dbs.melt は systemd だが。
#	install -m 0755 yatt_monitor.service /etc/init.d/yatt_monitor
#	update-rc.d yatt_monitor defaults

gems:
	gem install sequel mysql2

clean:
	${RM} *~ .\#* *.bak
