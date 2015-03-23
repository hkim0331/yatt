# debug

start monitor at localhost:23002 by;

`````
$ ./yatt_monitor.rb
````

then yatt.

````
$ ./yatt.rb --server localhost
````

## why?

* クライアント名

mariadb側、host=yatt.melt.kyutech.ac.jp だと、

````
ERROR 1130 (HY000): Host 'apache24.melt.kyutech.ac.jp' is not allowed to connect to this MariaDB server
````

はなぜ？
