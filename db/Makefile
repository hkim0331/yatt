# VERSION: 0.11

DB=yatt.db

create:
	sqlite3 ${DB} < create.sql

drop:
	sqlite3 ${DB} < drop.sql

clean:
	${RM} ${DB} *~

schema:
	echo '.schema' | sqlite3 ${DB} > $@

dump:
	echo '.dump' | sqlite3 ${DB} > yatt.sqlite3

yatt.sql: yatt.sqlite3
	sed -e 's/primary key/primary key auto_increment/' \
	-e 's/"yatt"/yatt (id, uid, score, updated_at)/g' $? > $@
