drop table if exists yatt;
create table yatt (
    id  integer primary key,
    uid varchar(8) not null,
    score   int,
    updated_at datetime not null);
