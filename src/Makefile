# VERSION: 1.1.1

all:
	@echo "'make osx' to install on osx(develop)."
	@echo "'make isc' to install on isc."
	@echo "'make linux' to install on general linuxen."
	@echo "'make monitor' to install yatt monitor under ${YATT_MONITOR}."

macos: osx

osx:
	mkdir -p ${HOME}/bin
	${RM} ${HOME}/bin/yatt
	ln -s ${PWD}/yatt.rb ${HOME}/bin/yatt

isc:
	mkdir -p /edu/lib/yatt
	install -m 0755 *.rb /edu/lib/yatt
	${RM} /edu/bin/yatt
	ln -s /edu/lib/yatt/yatt.rb /edu/bin/yatt
	sed -i --follow-symlinks '1 c\
#!/edu/bin/ruby' /edu/bin/yatt

linux:
	mkdir -p /opt/lib/yatt /opt/bin
	install -m 0755 *.rb /opt/lib/yatt
	${RM} /opt/bin/yatt
	ln -s /opt/lib/yatt/yatt.rb /opt/bin/yatt
# with ruby2.3-tcltk installed, yatt works. 2018-03-20
#	sed -i --follow-symlinks '1 c\
##!/opt/bin/ruby' /opt/bin/yatt

monitor: gems
	mkdir -p /srv/yatt/bin /srv/yatt/log
	install -m 0755 yatt_monitor.rb /srv/yatt/bin
	install yatt-monitor.service /etc/systemd/system/
	systemctl enable yatt-monitor
	systemctl start yatt-monitor
	@echo 'do not forget to open monitor port(default 4001/tcp).'

gems:
	gem install sequel mysql2

clean:
	${RM} *~ .\#* *.bak
