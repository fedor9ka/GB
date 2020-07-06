
-- Практическое задание по теме «Операторы, фильтрация, сортировка и ограничение»
-- 1.	Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

DROP TABLE IF EXISTS users;

CREATE TABLE users (
id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR (255),
created_at DATETIME,
updated_at DATETIME
);

INSERT INTO
  users (name, created_at, updated_at)
VALUES
  ('Владимир', NULL, NULL),
  ('Наталья', NULL, NULL),
  ('Алексей', NULL, NULL),
  ('Наталья', NULL, NULL),

UPDATE users SET created_at = NOW(), updated_at = NOW();

-- 2.	Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. 
--      Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.

DROP TABLE IF EXISTS users;

CREATE TABLE users (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR (255),
created_at VARCHAR (255),
updated_at VARCHAR (255)
);

INSERT INTO users (created_at, updated_at) VALUES
  ('20.10.2017 8:10', '20.10.2017 8:10'),
  ('20.10.2017 8:10', '20.10.2017 8:10'),
  ('20.10.2017 8:10', '20.10.2017 8:10'),
  ('20.10.2017 8:10', '20.10.2017 8:10');

UPDATE users SET created_at = STR_TO_DATE('20.10.2017 8:10', '%d.%m.%Y %h:%i');

UPDATE users SET updated_at = STR_TO_DATE('20.10.2017 8:10', '%d.%m.%Y %h:%i');

ALTER TABLE users MODIFY COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE users MODIFY COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- 3.	В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы.
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.

DROP TABLE IF EXISTS storehouses_products;

CREATE TABLE storehouses_products (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
value INT UNSIGNED NOT NULL,
created_at VARCHAR (255),
updated_at VARCHAR (255)
);

INSERT INTO storehouses_products (value) VALUES
  ('0'),
  ('2500'),
  ('0'),
  ('15'),
  ('30'),
  ('0');

SELECT MAX(value) FROM storehouses_products;

SELECT id, value FROM storestorehouses_products ORDER BY CASE WHEN value = 0 THEN 2501 ELSE value END;


-- Практическое задание теме «Агрегация данных»
-- 1.	Подсчитайте средний возраст пользователей в таблице users.

DROP TABLE IF EXISTS users;

CREATE TABLE users (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR (255),
birthday_at DATE,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO users (birthday_at) VALUES
  ('1975-07-30'),
  ('1961-07-21'),
  ('1999-08-01'),
  ('1945-06-22'),
  ('1931-12-02');

SELECT
  AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS age
FROM users;

-- 2.	Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели текущего года, а не года рождения.

-- не получилось






