yatt.txt: constitution.txt GNU_COPYING.txt moby-dick.txt
	ruby pack.rb $?  > $@

isc: clean yatt.txt
	if [ ! -d /edu/lib/yatt ]; then \
		mkdir /edu/lib/yatt; \
	fi
	cp yatt.txt yatt4.gif README /edu/lib/yatt/

osx: clean yatt.txt
	if [ ! -d ${HOME}/Library/yatt ]; then \
		mkdir ${HOME}/Library/yatt; \
	fi
	cp yatt.txt yatt4.gif README ${HOME}/Library/yatt/

linux: clean yatt.txt
	if [ ! -d ${HOME}/lib/yatt ]; then \
		mkdir -p ${HOME}/lib/yatt; \
	fi
	cp yatt.txt yatt4.gif README ${HOME}/lib/yatt/

clean:
	${RM} *~ .\#*$ yatt.txt
