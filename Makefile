all: install

install:
	@echo "'make linux' to install on linux."
	@echo "'make macos' to install on macOS."
	@echo "'make isc' to install on isc."
	@echo "'make monitor' to install yatt-monitor locally."
	@echo "'make melt' to make /Volumes/Data/Share/yatt/yatt-${VERSION}.tar"

isc:
	(cd src && make isc)
	(cd lib && make isc)

linux:
	(cd src && make linux)
	(cd lib && make linux)

osx:
	(cd src && make osx)
	(cd lib && make osx)

melt:
	@echo 'not ready.'

monitor:
	(cd src && make monitor)

clean:
	${RM} *~ .\#*
	find ./ -name \*.bak -exec rm {} \;
