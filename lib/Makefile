yatt.txt: constitution.txt GNU_COPYING.txt moby-dick.txt
	ruby pack.rb $?  > $@

isc: yatt.txt yatt.gif
	if [ ! -d /edu/lib/yatt ]; then \
		mkdir /edu/lib/yatt; \
	fi
	cp yatt.txt yatt.gif yatt3.gif README /edu/lib/yatt/

osx: yatt.txt yatt.gif
	if [ ! -d ${HOME}/Library/yatt ]; then \
		mkdir ${HOME}/Library/yatt; \
	fi
	cp yatt.txt yatt.gif yatt3.gif README ${HOME}/Library/yatt/

linux: yatt.txt yatt.gif
	if [ ! -d ${HOME}/lib/yatt ]; then \
		mkdir -p ${HOME}/lib/yatt; \
	fi
	cp yatt.txt yatt.gif yatt3.gif README ${HOME}/lib/yatt/

clean:
	${RM} *~ .\#*$ yatt.txt
