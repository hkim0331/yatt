# VERSION: 0.25

DB = yatt.db

create:
	sqlite3 ${DB} < create.sql

drop:
	sqlite3 ${DB} < drop.sql

schema:
	sqlite3 -line ${DB} '.schema' > $@

clean:
	${RM} schema yatt.sqlite3 yatt.mysql *.bak *~

# for migration from sqlite3 to mysql
yatt.sqlite3:
	echo '.dump' | sqlite3 ${DB} > yatt.sqlite3

yatt.mysql: yatt.sqlite3
	sed -e 's/PRAGMA/# PRAGMA/' \
		-e 's/BEGIN TRANSACTION/START TRANSACTION/' \
		-e 's/primary key/primary key auto_increment/' \
		-e 's/"yatt"/yatt (id, uid, score, updated_at)/g' $? > $@
