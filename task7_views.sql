-- представления (минимум 2);

-- создадим представления, в котором будут храниться название страны и соответсвующие ему назавания городов в отсортированном порядке

CREATE OR REPLACE VIEW region AS
  SELECT
    c.country_name AS country,
    c2.city_name AS city
  FROM countries c
    JOIN cities c2 
      ON c.id = c2.country_id
  ORDER BY country, city;
 
SELECT * FROM region LIMIT 10;

-- создадим предсталение, которое будет хранить:  наименование объектов размещения, владелец которых имеет флаг super_owner, по городам 
-- в отсортированном порядке

CREATE OR REPLACE VIEW super_owner AS
  SELECT DISTINCT city_name AS city, title AS property_name, filename AS photo
  FROM property
    LEFT JOIN owners
      ON property.owner_id = owners.user_id
    LEFT JOIN cities
      ON property.city_id = cities.id
    LEFT JOIN property_photos
      ON property.id = property_photos.property_id 
    LEFT JOIN photos
      ON property_photos.property_id = photos.id
  WHERE owners.super_owner = TRUE
  ORDER BY city;

SELECT * FROM super_owner LIMIT 10;

-- создадим представление, которое будет хранить все негативные отзывы (с рейтингом 1) об объекте размещения отсортированное по городам

CREATE OR REPLACE VIEW negative_reviews AS
  SELECT DISTINCT city_name AS city, title AS property_name, body AS review
  FROM property
    LEFT JOIN cities
      ON property.city_id = cities.id
    LEFT JOIN reviews
      ON property.id = reviews.target_id AND reviews.target_type = 'Объект размещения'
  WHERE reviews.rating = 1
  ORDER BY city;
 
SELECT * FROM negative_reviews LIMIT 10;

-- Создадим пользователя, который не будет иметь доступа к таблицам БД airbnb, однако сможет извлекать записи из представлений.

CREATE USER 'user_read'@'localhost' IDENTIFIED WITH sha256_password BY 'pass';

-- выдало ошибку
USE mysql;
SELECT user FROM user;

-- такой пользователь уже существует
DROP USER user_read@localhost;
USE airbnb;

GRANT SELECT ON airbnb.region TO 'user_read'@'localhost';
GRANT SELECT ON airbnb.super_owner TO 'user_read'@'localhost';
GRANT SELECT ON airbnb.negative_reviews TO 'user_read'@'localhost';

