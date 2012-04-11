# VERSION: 0.13

all:
	@echo "'make osx' to install on osx(develop)."
	@echo "'make isc' to install on isc."
	@echo "'make linux' to install on general linuxen."

isc: yatt.isc yatt.rb
	install -m 0755 yatt.rb /edu/bin/yatt.rb
	install -m 0755 yatt.isc /edu/bin/yatt

osx: yatt.osx yatt.rb
	install -m 0755 yatt.rb /Users/hkim/bin/yatt.rb
	install -m 0755 yatt.osx /Users/hkim/bin/yatt

linux: yatt.linux yatt.rb
	install -m 0755 yatt.rb /home/hkim/bin/yatt.rb
	install -m 0755 yatt.linux /home/hkim/bin/yatt

server: yatt_server.rb yatt_server
	install -m 0755 yatt_server.rb /usr/local/bin
	install -m 0755 yatt_server /usr/local/bin

clean:
	${RM} *~ .\#* *.bak
