-- Практическое задание по теме “Транзакции, переменные, представления”
 -- 1.	В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 
 -- из таблицы shop.users в таблицу sample.users. Используйте транзакции.
SHOW DATABASES;
USE shop;

SHOW TABLES;
SELECT * FROM users;

USE sample;

SHOW TABLES;
SELECT * FROM users;

START TRANSACTION;

INSERT INTO sample.users SELECT * FROM shop.users WHERE shop.users.id = 1;

COMMIT;

-- 2.	Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название 
-- каталога name из таблицы catalogs.

USE shop;

SELECT * FROM products;
SELECT * FROM catalogs;

CREATE OR REPLACE VIEW existence (name, catalog_name)
  AS SELECT products.name, catalogs.name
    FROM products
      LEFT JOIN catalogs
    ON products.catalog_id = catalogs.id;
   
SELECT * FROM existence;

-- 3.(по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за
-- август 2018 года '2018-08-01', '2018-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат 
-- за август, выставляя в соседнем поле значение 1, если дата присутствует в исходной таблице и 0, если она отсутствует.

USE sample;

DROP TABLE IF EXISTS dates;
CREATE TABLE dates (stage DATE);

INSERT INTO dates VALUES
  ('2018-08-01'),
  ('2018-08-04'),
  ('2018-08-16'),
  ('2018-08-17');
  
SELECT * FROM dates;

SET @end := '2018-08-31';

-- корявое решение формирования списка дат, циклом бы как-нибудь пройтись по диапазону
SELECT august.day, 
(SELECT EXISTS (SELECT * FROM dates WHERE dates.stage = august.day))
   FROM (
SELECT DATE_SUB(@end, INTERVAL 30 DAY) AS day
  UNION
SELECT DATE_SUB(@end, INTERVAL 29 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 28 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 27 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 26 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 25 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 24 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 23 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 22 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 21 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 20 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 19 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 18 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 17 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 16 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 15 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 14 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 13 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 12 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 11 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 10 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 9 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 8 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 7 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 6 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 5 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 4 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 3 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 2 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 1 DAY)
  UNION
SELECT DATE_SUB(@end, INTERVAL 0 DAY)) AS august;

-- 4.	(по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие
-- записи из таблицы, оставляя только 5 самых свежих записей.


DROP TABLE IF EXISTS created_tbl;
CREATE TABLE created_tbl (created_at DATETIME);

INSERT INTO created_tbl VALUES
  ('2020-07-05'),
  ('2020-06-04'),
  ('2019-07-05'),
  ('2020-03-11'),
  ('2020-01-15'),
  ('2020-01-19'),
  ('2020-04-03'),
  ('2017-06-01'),
  ('2011-07-16'),
  ('2020-03-19');
 
SELECT * FROM created_tbl;

CREATE VIEW recent5 AS
  SELECT * FROM created_tbl ORDER BY created_at DESC LIMIT 5;

-- решение
DELETE FROM created_tbl WHERE created_at NOT IN (SELECT * FROM recent5);

SELECT * FROM recent5;

-- Практическое задание по теме “Администрирование MySQL” 
-- 1.	Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть доступны
-- только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop.


SHOW DATABASES;
USE shop;

CREATE USER 'shop_read'@'localhost' IDENTIFIED WITH sha256_password BY 'pass';
GRANT SELECT ON shop.* TO 'shop_read'@'localhost';

CREATE USER 'shop'@'localhost' IDENTIFIED WITH sha256_password BY 'pass';
GRANT ALL ON shop.* TO 'shop'@'localhost';
GRANT GRANT OPTION ON shop.* TO 'shop'@'localhost';

-- 2.	(по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ,
-- имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.
-- Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из 
-- представления username.

USE sample;

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL);
  
INSERT INTO accounts (name, `password`) VALUES
  ('Vladmir', '123'),
  ('Elisey', '134'),
  ('Vasiliy', '159'),
  ('Ivan', '111');
 
SELECT * FROM accounts;

CREATE OR REPLACE VIEW user_accounts(user_id, user_name) AS SELECT id, name FROM accounts;

SELECT * FROM user_accounts;

CREATE USER 'user_read'@'localhost' IDENTIFIED WITH sha256_password BY 'pass';

GRANT SELECT ON sample.user_accounts TO 'user_read'@'localhost';

-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"
-- 1.	Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу 
-- "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DROP FUNCTION IF EXISTS hello;

DELIMITER //

CREATE FUNCTION hello()
RETURNS TINYTEXT NO SQL
BEGIN
  DECLARE hour INT;
  SET hour = HOUR(NOW());
	CASE 
		WHEN hour BETWEEN 6 AND 11 THEN
			RETURN 'Доброе утро';
		WHEN hour BETWEEN 12 AND 17 THEN
			RETURN 'Добрый день';
		WHEN hour BETWEEN 18 AND 23 THEN
			RETURN 'Добрый вечер';
		ELSE
			RETURN 'Доброй ночи';
	END CASE;
END //

DELIMITER ;

SELECT hello();

-- 2.	В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие 
-- обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, 
-- добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо 
-- отменить операцию.

USE shop;

SELECT * FROM products;

DROP TRIGGER IF EXISTS not_null;

DELIMITER //

CREATE TRIGGER nullTrigger BEFORE INSERT ON products 
FOR EACH ROW
BEGIN 
	IF(ISNULL(NEW.name) AND ISNULL(NEW.description)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Warning! Both fields: name and description are NULL!';
	END IF;
END //

DELIMITER ;

-- проверка

INSERT INTO products (name, description) VALUES
  (NULL, NULL);
