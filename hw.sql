-- Тема “Сложные запросы”
-- 1.	Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
USE shop;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Заказы';

INSERT INTO orders (user_id) VALUES 
 (1),
 (3),
 (6),
 (1);

-- решение 

SELECT name FROM users
  WHERE id IN (SELECT user_id FROM orders);

-- 2.	Выведите список товаров products и разделов catalogs, который соответствует товару.

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';
 
INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);
 
 DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела'
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

-- решение

SELECT p.name, c.name FROM
  products AS p
JOIN
  catalogs AS c
    ON p.catalog_id = c.id;
    
-- 3.	(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.
   
DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `from` VARCHAR(255),
  `to` VARCHAR(255));
  
INSERT INTO flights (`from`, `to`) VALUES 
  ('Moscow', 'Omsk'),
  ('Novgorod', 'Kazan'),
  ('Irkutsk', 'Moscow'),
  ('Omsk', 'Irkutsk'),
  ('Moscow', 'Kazan');
  
DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
  label VARCHAR(255),
  name VARCHAR(255));
  
INSERT INTO cities VALUES
  ('Moscow', 'Москва'),
  ('Irkutsk', 'Иркутск'),
  ('Omsk', 'Омск'),
  ('Novgorod', 'Новгород'),
  ('Kazan', 'Казань');

 SELECT * FROM flights;
 SELECT * FROM cities;

SELECT cities.name, flights.id FROM 
  cities 
JOIN
 flights
   ON flights.`from` = cities.label; -- преобразовали город вылета к русскому
  
  
SELECT cities.name, flights.id FROM 
  cities 
JOIN
 flights
   ON flights.`to` = cities.label; -- преобразовали город прилёта к русскому
  
 
-- Оборачиваем SELECTOM каждый из 2-ух предыдущих запросов и JOINим с условием равенства id

SELECT `from`.name, `to`.name FROM 
(SELECT cities.name, flights.id FROM 
  cities 
JOIN
 flights
   ON flights.`from` = cities.label) AS `from`
JOIN 
(SELECT cities.name, flights.id FROM 
  cities 
JOIN
 flights
   ON flights.`to` = cities.label) AS `to`
  USING(id)
   ORDER BY id;
