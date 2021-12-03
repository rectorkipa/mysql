CREATE DATABASE example;

USE example;

CREATE TABLE users(
	id INT,
	name VARCHAR(30)
);



C:\Program Files\MySQL\MySQL Server 8.0\bin>mysqldump example > c:\testsql\test_1.sql

C:\Program Files\MySQL\MySQL Server 8.0\bin>mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 47
Server version: 8.0.27 MySQL Community Server - GPL

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> CREATE DATABASE sample;
Query OK, 1 row affected (0.04 sec)

mysql> exit
Bye

C:\Program Files\MySQL\MySQL Server 8.0\bin>mysql sample < c:\testsql\test_1.sql

C:\Program Files\MySQL\MySQL Server 8.0\bin>