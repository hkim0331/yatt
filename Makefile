all: install

install:
	(cd src && make install)
	(cd lib && make install)

clean:
	${RM} *~ .\#*
