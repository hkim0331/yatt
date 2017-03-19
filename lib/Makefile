yatt.txt: constitution.txt GNU_COPYING.txt moby-dick.txt
	ruby pack.rb $?  > $@

isc: clean yatt.txt
	mkdir -p /edu/lib/yatt
	cp yatt.txt yatt4.gif README /edu/lib/yatt/

osx: clean yatt.txt
	mkdir -p ${HOME}/Library/yatt
	cp yatt.txt yatt4.gif README ${HOME}/Library/yatt/

linux: clean yatt.txt
	mkdir -p /opt/lib/yatt
	cp yatt.txt yatt4.gif README /opt/lib/yatt/

clean:
	${RM} *~ .\#*$ yatt.txt
