all: install

install:
	@echo "'make linux' to install on linux."
	@echo "'make macos' to install on macOS."
	@echo "'make isc' to install on isc."
	@echo "'make monitor' to install yatt-monitor locally."

isc:
	(cd src && make isc)
	(cd lib && make isc)

linux:
	(cd src && make linux)
	(cd lib && make linux)

macos:
	(cd src && make osx)
	(cd lib && make osx)

melt:
	@echo 'not ready.'

monitor:
	(cd src && make monitor)

clean:
	${RM} *~ .\#*
	find ./ -name \*.bak -exec rm {} \;
