-- Практическое задание по теме “Оптимизация запросов”
-- 1.	Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается время и 
-- дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

USE shop;

DESC users;
DESC catalogs;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  table_name VARCHAR(100),
  row_id INT NOT NULL,
  name VARCHAR(255)
) ENGINE=Archive;

-- создаём триггер на users
DELIMITER //

CREATE TRIGGER users_log AFTER INSERT ON users
FOR EACH ROW BEGIN
	INSERT INTO logs VALUES ( 
	  NEW.created_at,
	  'users',
	  NEW.id,
	  NEW.name);
END//

DELIMITER ;

-- проверка

INSERT INTO users(name) VALUES ('Oleg');
SELECT * FROM logs;
SELECT * FROM users;


-- создаём триггер на catalogs
DELIMITER //

CREATE TRIGGER catalogs_log AFTER INSERT ON catalogs
FOR EACH ROW BEGIN
	INSERT INTO logs(table_name, row_id, name) VALUES ( 
	  'catalogs',
	  NEW.id,
	  NEW.name);
END//

DELIMITER ;

-- проверка
INSERT INTO catalogs(name) VALUES ('SSD');
SELECT * FROM logs;
SELECT * FROM catalogs;


-- 2.	(по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
DESC users;
SELECT * FROM users;

CREATE TEMPORARY TABLE names (name VARCHAR(100));

INSERT INTO names VALUES
  ('Геннадий'),
  ('Наталья'),
  ('Александр'),
  ('Сергей'),
  ('Иван'),
  ('Мария'),
  ('Виктор'),
  ('Любовь');

DELIMITER //

CREATE PROCEDURE insert_million()
BEGIN
	DECLARE i INT DEFAULT 0;
    WHILE i <= 1000000 DO
      INSERT INTO users(name) VALUES((SELECT name FROM names ORDER BY RAND() LIMIT 1))
      SET i = i + 1;
    END WHILE;
END//

DELIMITER ;

CALL insert_million();


-- Практическое задание по теме “NoSQL”
-- 1.	В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

HSET ip_adresses '192.168.1.1' 0
HINCRBY ip_adresses '192.168.1.1' 1
HGET ip_adresses '192.168.1.1'

-- 2.	При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, поиск электронного адреса пользователя по его имени.

SET neo@mail.ru neo 
SET neo neo@mail.ru

GET neo@mail.ru 
GET neo 

-- 3.	Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.

use shop

db.createCollection('catalogs')
db.catalogs.insertMany([{"name": "Процессоры"}, {"name": "Мат.платы"}, {"name": "Видеокарты"}])

db.createCollection('products')
db.products.insertMany([
	{"name": "AMD FX-8320", "description": "Процессор для настольных персональных компьютеров, основанных на платформе AMD", "price": "4780.00", "catalog_id": "1", "created_at": new Date(), "updated_at": new Date()},
	{"name": "AMD FX-8320E", "description": "Процессор для настольных персональных компьютеров, основанных на платформе AMD", "price": "7120.00", "catalog_id": "1", "created_at": new Date(), "updated_at": new Date()},
	{"name": "ASUS ROG MAXIMUS X HERO", "description": "Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX", "price": "19310.00", "catalog_id": "2", "created_at": new Date(), "updated_at": new Date()}])

 

