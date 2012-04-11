yatt.txt: constitution.txt GNU_COPYING.txt
	ruby pack.rb $^ > $@

isc: yatt.txt yatt.gif
	if [ ! -d /edu/lib/yatt ]; then \
		mkdir /edu/lib/yatt; \
	fi
	cp yatt.txt yatt.gif /edu/lib/yatt/

osx: yatt.txt yatt.gif
	if [ ! -d /Users/hkim/Library/yatt ]; then \
		mkdir /Users/hkim/Library/yatt; \
	fi
	cp yatt.txt yatt.gif /Users/hkim/Library/yatt/

linux: yatt.txt yatt.gif
	if [ ! -d /home/hkim/lib/yatt ]; then \
		mkdir /home/hkim/lib/yatt; \
	fi
	cp yatt.txt yatt.gif /home/hkim/lib/yatt/

clean:
	${RM} *~ .\#*$ yatt.txt
