-- скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные запросы);

-- Выборка данных по пользователю (сначала подсмотрим у каких пользователей есть рейтинг в reviews)

SELECT * FROM reviews r2 ORDER BY target_type, target_id LIMIT 10;

SELECT first_name, last_name, ANY_VALUE(city_name) AS city_name, ANY_VALUE(country_name) AS country_name, AVG(rating)
  FROM users
    LEFT JOIN profiles
      ON users.id = profiles.user_id
    LEFT JOIN countries
      ON profiles.country_id = countries.id
    LEFT JOIN cities
      ON profiles.city_id = cities.id
    LEFT JOIN reviews
      ON users.id = reviews.target_id AND target_type = 'Гость'
  WHERE users.id = 14;
 
SELECT @@session.sql_mode;

-- Выборка данных по объекту размещения

SELECT * FROM reviews r2 ORDER BY target_type DESC, target_id LIMIT 10;

SELECT title, description, city_name, country_name, price, ANY_VALUE(filename), AVG(rating)
  FROM property
    LEFT JOIN countries
      ON property.country_id = countries.id
    LEFT JOIN cities
      ON property.city_id = cities.id
    LEFT JOIN owners
      ON property.owner_id = owners.user_id 
    LEFT JOIN photos
      ON property.owner_id = photos.user_id
    LEFT JOIN reviews
      ON property.id = reviews.target_id AND target_type = 'Объект размещения'
  WHERE property.id = 13;
 
 -- Выборка сообщений от пользователя в к пользователю
 
SELECT messages.from_user_id, messages.to_user_id, messages.body, messages.created_at
  FROM users
    JOIN messages
      ON users.id = messages.to_user_id
        OR users.id = messages.from_user_id
  WHERE users.id = 13;
 
 -- Вывести 5 объектов с максимальным рейтингом по каждому городу

 SELECT property_name, city_name, rating
  FROM (
  SELECT DISTINCT property.title AS property_name, city_name, AVG(rating) AS rating,
    ROW_NUMBER() OVER (PARTITION BY city_name ORDER BY city_name, AVG(rating) DESC) AS row_num
    FROM property
      LEFT JOIN cities
        ON property.city_id = cities.id
      LEFT JOIN reviews
        ON property.id = reviews.target_id AND target_type = 'Объект размещения'
      GROUP BY property.id
  ) AS top_5
  WHERE row_num BETWEEN 1 AND 5;
 
   
 EXPLAIN SELECT DISTINCT property.title AS property_name, city_name, AVG(rating) AS rating,
  ROW_NUMBER() OVER (PARTITION BY city_name ORDER BY city_name, AVG(rating) DESC) AS 'row_number'
  FROM property
    LEFT JOIN cities
      ON property.city_id = cities.id
    LEFT JOIN reviews
      ON property.id = reviews.target_id AND target_type = 'Объект размещения'
    GROUP BY property.id;
   -- Во всех запросах с участием таблицы reviews, происходит перебор всех строк при участии столбцов target_id (и target_type).
   -- Прописать на него внешний ключ или индекс нельзя в силу того, что он ссылается на разные таблицы. В силу того что таких запросов будет
   -- значительное количество, в целях оптимизации имеет смысл разнести отзывы о guests и owners по разным таблицам, настроить внешние ключи.

-- Вывести 5 самых дешёвых вариантов жилья в определенном городе на заданный период

DESC property;
SET @start_date := '2020-09-01';
SET @end_date := '2020-09-10';

SELECT DISTINCT property.title AS property_name, ANY_VALUE(filename),
  ABS(DATEDIFF(@start_date, @end_date)) * price AS price
  FROM property
    LEFT JOIN cities
      ON property.city_id = cities.id
    LEFT JOIN photos
      ON property.owner_id = photos.user_id
    LEFT JOIN bookings
      ON property.id = bookings.property_id
  WHERE city_name = 'Sierraland'
  GROUP BY property.id
  ORDER BY price
  LIMIT 5;

