-- правка данных
SHOW TABLES;

-- Анализируем данные пользователей

DESC users;
SELECT * FROM users LIMIT 10;

-- в таблице owners у нас всего 50 пользователей, приведем количество флагов is_owner = TRUE в соответствие

UPDATE users SET
  is_owner = IF (users.id IN (SELECT user_id FROM owners), TRUE, FALSE);

-- Приводим в порядок временные метки
UPDATE users SET created_at = CURRENT_TIMESTAMP 
  WHERE created_at < (SELECT birthday FROM profiles
    WHERE users.id = profiles.user_id);

UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE created_at > updated_at;

DESC profiles;
SELECT * FROM profiles LIMIT 10;

UPDATE profiles SET created_at = CURRENT_TIMESTAMP WHERE created_at < birthday;

UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE created_at > updated_at;

DESC owners;
-- Столбец id избыточен, удаляем

ALTER TABLE owners DROP COLUMN id;

SELECT * FROM owners LIMIT 10;
-- флаг super_owner не выставлен. Проставим для пользователей с нечетным id

UPDATE owners SET 
  super_owner = IF (user_id % 2, TRUE, FALSE);

DESC countries;
SELECT * FROM countries LIMIT 10;

DESC cities;
SELECT * FROM cities LIMIT 10;

DESC property;
SELECT * FROM property LIMIT 10;
-- не заполнены цены оказались, и значение в столбце owner_id должно соответствовать значению owners.user_id, которое мы правили выше

UPDATE property SET 
  price = (SELECT (1500 + RAND() * 5000));

UPDATE property SET
  owner_id = (SELECT user_id FROM owners ORDER BY RAND() LIMIT 1);
 
DESC photos;
-- столбец metadata после вставки значений изменил тип данных с JSON на longtext

ALTER TABLE photos MODIFY COLUMN metadata JSON;

SELECT * FROM photos LIMIT 10;
-- формат столбца filename не имеет расширения, создадим временную таблицу форматов, заполним значениями и обновим ссылки на фото

CREATE TEMPORARY TABLE extensions (name VARCHAR(10));

INSERT INTO extensions VALUES ('jpeg.'), ('png.'), ('tiff.'), ('bmp.');

SELECT * FROM extensions;

UPDATE photos SET filename = CONCAT('https://dropbox/airbnb/',
  filename,
  (SELECT name FROM extensions ORDER BY RAND() LIMIT 1)
);

-- заполним столбец metadata
UPDATE photos SET metadata = CONCAT('{"owner":"', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE users.id = photos.user_id),
  '"}');
 
DESC property_photos;
SELECT * FROM property_photos LIMIT 10;

DESC bookings;
SELECT * FROM bookings ORDER BY start_date DESC LIMIT 10;
-- пусть начало бронирования start_date приходится на текущий год, это пригодистя в последующем для запросов на доступность жилья

UPDATE bookings SET
  start_date = DATE_ADD('2020-01-01', INTERVAL (SELECT (FLOOR(1 + RAND() * 365))) DAY);

-- приведем в соответсвие даты начала и конца бронирования
UPDATE bookings SET
  end_date = DATE_ADD(start_date, INTERVAL (SELECT (FLOOR(7 + RAND() * 7))) DAY);
 
SELECT * FROM bookings LIMIT 10;

DESC reviews;
SELECT * FROM reviews LIMIT 10;
-- проверим наличие строк target_id в соответствущих 'Объекту размещения' и 'Гостях' таблицах: property и users

SELECT target_id FROM reviews
  WHERE target_type = 'Объект размещения'
    ORDER BY target_id DESC
      LIMIT 10;
     
SELECT target_id FROM reviews
  WHERE target_type = 'Гость'
    ORDER BY target_id DESC
      LIMIT 10;
     
DESC messages;
SELECT * FROM messages LIMIT 10;
-- формат общения между пользователя данного сервиса ограничен: quest/owner, в одной строке не может быть 2 quests или owners

UPDATE messages SET from_user_id =
  (CASE
     WHEN to_user_id IN (SELECT user_id FROM owners)
       THEN (SELECT id FROM users
         WHERE id NOT IN (SELECT user_id FROM owners) ORDER BY RAND() LIMIT 1)
     ELSE
       (SELECT user_id FROM owners ORDER BY RAND() LIMIT 1)
   END
    );
         




