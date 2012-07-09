all: install

install:
	@echo "'make linux' to install on linux."
	@echo "'make osx' to install on osx."
	@echo "'make isc' to install on isc."
	@echo "'make monitor' to install yatt-monitor locally."

isc:
	(cd src && make isc)
	(cd lib && make isc)

linux:
	(cd src && make linux)
	(cd lib && make linux)

osx:
	(cd src && make osx)
	(cd lib && make osx)

monitor:
	(cd src && make monitor)

clean:
	${RM} *~ .\#*
	find ./ -name \*.bak -exec rm {} \;
