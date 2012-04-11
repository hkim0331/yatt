all: install

install:
	(cd src && make install)
	(cd lib && make install)

linux:
	(cd src && make linux)
	(cd lib && make linux)

clean:
	${RM} *~ .\#*
	find ./ -name \*.bak -exec rm {} \;
