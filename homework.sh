sudo apt install mysql-server #установили MySQL
sudo systemctl status mysql
mysql -V
mysql -D
ls~
nano .my.cnf
#[mysql]
#user=root
#password=ytghjcnj Создали .my.cnf
mysql
CREATE DABASE example; #создали БД example
CREATE TABLE users (id INT, name VARCHAR(255) NOT NULL); #создали таблицу users
exit
mysqldump example > example.sql #создали dump
ls
mysql
CREATE DATABASE sample;
exit
mysql sample < example.sql #развернули содержание дампа в sample
mysqldump mysql help_keyword --where='TRUE ORDER BY help_keyword_id LIMIT 100' > help_keyword_report.sql #создали дамп mysql первых 100 строк
# таблицы help_keyword
