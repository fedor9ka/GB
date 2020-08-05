-- хранимые процедуры / триггеры;

-- для того, чтобы отслеживать пользователей, которые пытаются обмениваться номерами телефона в сообщениях (в циферном представлении)

DELIMITER //

DROP PROCEDURE IF EXISTS message_analysis//
CREATE PROCEDURE message_analysis()
BEGIN
	DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE message_id INT;
    DECLARE message_body TEXT;
   
    DECLARE reading_message CURSOR FOR SELECT id, body FROM messages;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN reading_message;
    
    read_loop: LOOP
      FETCH reading_message INTO message_id, message_body;
    
    IF DONE THEN
      LEAVE read_loop;
    END IF;
   
    SELECT CONCAT('Message_id ', message_id,
      IF(message_body LIKE '(?:\+|\d)[\d\-\(\) ]{8,}\d', " Warning!", " Fine!")) AS report; -- https://regex101.com/r/vLDk2h/1/
     
    END LOOP read_loop;
   
    CLOSE reading_message;
END//

DELIMITER ;

CALL message_analysis();
-- для выполнения запроса о доступности жилья на определенные даты, нам потребуется временная таблица с датами текущего года

DELIMITER //

DROP PROCEDURE IF EXISTS year_dates //
CREATE PROCEDURE year_dates (IN UID INT UNSIGNED)
BEGIN
	DROP TABLE IF EXISTS calendar;
	CREATE TABLE calendar(
	yeardate DATE NOT NULL PRIMARY KEY COMMENT 'Дата'
	) ENGINE=MyISAM COMMENT 'Календарь';
END //

DELIMITER ;

CALL year_dates(1);

-- проверим создалась ли таблица
SHOW TABLES;
DESC calendar;

-- теперь заполним ее датами текущего года

DELIMITER //

DROP PROCEDURE IF EXISTS filling_calendar //
CREATE PROCEDURE filling_calendar(IN `year` INT)
BEGIN
  DECLARE i INT;
  DECLARE i_end INT;
  SET i = 1;
  SET i_end = CASE 
                WHEN `year` % 4 THEN 365 
                ELSE 366 
              END;
  START TRANSACTION;
    WHILE i <= i_end DO
      INSERT INTO calendar VALUES (MAKEDATE(`year`, i));
      SET i = i + 1;
    END WHILE;
  COMMIT;
END//	
    
DELIMITER ;

-- теперь можно заполнять календарь датами любого года
CALL filling_calendar(2020);

SELECT * FROM calendar LIMIT 10;

-- Запрос на доступность дат конкретного объекта размещения. Будем извлекать недельные доступные блоки, 
-- в том случае, если недельный блок не пересекаются с забронированными датами объекта. Неделя будет начинаться с понедельника.

SELECT calendar.yeardate AS available_start,
  DATE_ADD(calendar.yeardate, INTERVAL 7 DAY) AS available_end
  FROM calendar
    LEFT JOIN (SELECT * FROM bookings WHERE property_id = 3) AS bookings
     ON 
       (calendar.yeardate BETWEEN bookings.start_date AND bookings.end_date)
     OR
        (DATE_ADD(calendar.yeardate, INTERVAL 7 DAY) BETWEEN bookings.start_date AND bookings.end_date)
WHERE
  bookings.id IS NULL AND WEEKDAY(calendar.yeardate) = 0;

-- проверим наличие пересечений
SELECT start_date, end_date 
  FROM bookings b2
    WHERE property_id = 3
      ORDER BY start_date;
     

-- Создание триггера для обработки target_id
 
-- Сначала создадим функцию для проверки существования строки с идентификатором target_id в соответствующей таблице,

DESC reviews;
SELECT * FROM reviews ORDER BY target_id DESC;

DELIMITER //

DROP FUNCTION IF EXISTS is_row_exists//
CREATE FUNCTION is_row_exists (obj_id INT, obj_type VARCHAR(50))
RETURNS BOOLEAN READS SQL DATA

BEGIN
  DECLARE table_name VARCHAR(50);
  SELECT target_type FROM reviews WHERE reviews.target_type = obj_type LIMIT 1 INTO table_name;

  CASE table_name
    WHEN 'Гость' THEN
      RETURN EXISTS(SELECT 1 FROM users WHERE users.id = obj_id);
    WHEN 'Объект размещения' THEN 
      RETURN EXISTS(SELECT 1 FROM property WHERE property.id = obj_id);
    ELSE 
      RETURN FALSE;
  END CASE;
  
END//

DELIMITER ;

SELECT is_row_exists(247, 'Гость');
SELECT is_row_exists(251, 'Объект размещения');
SELECT * FROM reviews ORDER BY target_id DESC LIMIT 10;
SELECT id FROM property ORDER BY id DESC LIMIT 10;
SELECT id FROM users ORDER BY id DESC LIMIT 10;

-- Создадим триггер для проверки валидности target_id и target_type
 
DROP TRIGGER IF EXISTS reviews_validation;
DELIMITER //

CREATE TRIGGER reviews_validation BEFORE INSERT ON reviews

FOR EACH ROW BEGIN
  IF !is_row_exists(NEW.target_id, NEW.target_type) THEN
    SIGNAL SQLSTATE "45000"
    SET MESSAGE_TEXT = "Error adding review! Target table doesn't contain row id provided!";
  END IF;
END//

DELIMITER ;

DESC reviews;
INSERT INTO reviews (user_id, target_id, target_type) VALUES (15, 15, 'Гость');
INSERT INTO reviews (user_id, target_id, target_type) VALUES (15, 251, 'Гость');

-- Ввиду того, что рейтинг пользователя или объекта размещения присутствует практически во многих запросах,
-- в таблице reviews существюут столбцы target_id и target_type, которые не индексируются:
-- следует рассмотреть вариант денормализации структуры БД. А именно, создать в таблицах owners и property
-- столбцы с рейтингом, где будет храниться уже вычисленный средний рейтинг пользователя, обновляя их с помощью
-- триггера при каждом добавлении отзыва.

ALTER TABLE users ADD COLUMN rating DECIMAL(3, 2);
ALTER TABLE property ADD COLUMN rating DECIMAL(3, 2);

-- триггер для users
DELIMITER //

CREATE TRIGGER user_rating_update AFTER INSERT ON reviews
FOR EACH ROW BEGIN
	UPDATE users SET rating = (
	  SELECT AVG(rating) FROM reviews 
	    WHERE target_id = users.id AND target_type = 'Гость' AND reviews.rating IS NOT NULL
	  )
	 WHERE NEW.target_id = users.id;
END //


DELIMITER ;

-- Актуализируем данные в столбце rating

UPDATE users SET rating = 
  (SELECT AVG(rating) FROM reviews 
     WHERE users.id = reviews.target_id AND target_type = 'Гость' AND reviews.rating IS NOT NULL);
    
    
 -- проверим работу триггера
SELECT rating FROM users WHERE id = 2; -- рейтинг 5
-- внесем запись в таблицу отзывов и проверим работу триггера
INSERT INTO reviews (user_id, rating, target_id, target_type) VALUES (2, 1, 2, 'Гость');

SELECT rating FROM users WHERE id = 2; -- рейтинг 3

-- тоже самое для property
DELIMITER //

CREATE TRIGGER property_rating_update AFTER INSERT ON reviews
FOR EACH ROW BEGIN
	UPDATE property SET rating = (
	  SELECT AVG(rating) FROM reviews 
	    WHERE target_id = property.id AND target_type = 'Объект размещения' AND reviews.rating IS NOT NULL
	  )
	 WHERE NEW.target_id = property.id;
END //

DELIMITER ;

UPDATE property SET rating = 
  (SELECT AVG(rating) FROM reviews 
     WHERE property.id = reviews.target_id AND target_type = 'Объект размещения' AND reviews.rating IS NOT NULL);
-- Напоследок создадим триггер, который будет отвечать за флаг super_owner таблицы owners,
-- пусть собственников объектов жилья, средний рейтинг которых > 4,3 получают флаг super_owner, для
-- этого так же необходимо добавить столбец avg_rating в таблицу owners;

ALTER TABLE owners ADD COLUMN avg_rating DECIMAL(3, 2);

-- обновляем данные
UPDATE owners SET avg_rating = (
  SELECT avg_rating FROM (SELECT user_id, AVG(rating) AS avg_rating
   FROM owners 
     JOIN property
       ON property.owner_id = owners.user_id
     WHERE rating IS NOT NULL
   GROUP BY owner_id
  ) AS temp WHERE owners.user_id = temp.user_id);



-- создаем триггер, поддерживающий данные столбца avg_rating актуальными

DELIMITER //

CREATE TRIGGER owners_avg_rating_update AFTER INSERT ON reviews
FOR EACH ROW BEGIN
  UPDATE owners SET avg_rating = (
  SELECT avg_rating FROM (SELECT user_id, AVG(rating) AS avg_rating
   FROM owners 
     JOIN property
       ON property.owner_id = owners.user_id
     WHERE rating IS NOT NULL
   GROUP BY owner_id
  ) AS temp WHERE owners.user_id = temp.user_id);
    END //

DELIMITER ;
 

-- проверим работу триггера
SELECT user_id, avg_rating FROM owners ORDER BY user_id DESC;
SELECT * FROM property p2 WHERE owner_id = 195;
SELECT avg_rating FROM owners WHERE owners.user_id = 195; -- 3,8 рейтинг

INSERT INTO reviews (user_id, rating, target_id, target_type) VALUES (15, 1, 175, 'Объект размещения');

SELECT avg_rating FROM owners WHERE owners.user_id = 195; -- 3,6 рейтинг

-- наконец создадим триггер, отвечающий за флаг super_owner

DELIMITER //

CREATE TRIGGER owners_super_owner_update AFTER UPDATE ON reviews
FOR EACH ROW BEGIN
	UPDATE owners SET super_owner = 
	  CASE
	    WHEN owners.avg_rating > 4.3 THEN TRUE
	    ELSE FALSE 
	  END;
END //

DELIMITER ;



