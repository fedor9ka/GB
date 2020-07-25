-- Задания на БД vk:

-- 1. Проанализировать какие запросы могут выполняться наиболее
-- часто в процессе работы приложения и добавить необходимые индексы.

-- Вопросы к предыдущеум уроку: для чего нужны уникальные индексы, если СУБД сама неявно создвет индесы на столбцы, для которых мы определяем 
-- ограничение уникальности UNIQUE? 

USE vk;
-- Запросы на выбoрку данных по пользователю, составной индекс

DESC users;
SHOW INDEX FROM users;

CREATE INDEX users_first_name_last_name_idx
  ON users(first_name, last_name);
 
 -- Все запросы на выборку фото, аудио, медиафайлов пользователя связаны со столбцами, которые поределены как внешние ключи,
 -- соответственно индексы на них уже есть, а в таблице media_types всего 3 значения, что не сильно увеличит скорость обработки
 
 -- Запросы на формирование сообщений, составной индекс
 
DESC messages;
SHOW INDEX FROM messages;

CREATE INDEX messages_from_user_id_to_user_id_idx ON messages (from_user_id, to_user_id);

-- 2. Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый старший пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

-- Для начала построим запрос традиционным способом
DESC communities_users;
SELECT *  FROM communities_users;

DESC communities;
SELECT *  FROM communities;

SELECT c.name,
  cu.user_id,
  p.birthday
  FROM communities_users cu
    JOIN communities c 
      ON cu.community_id = c.id
    JOIN profiles p 
      ON cu.user_id = p.user_id
  ORDER BY name, birthday DESC;
 
 SELECT c.name,
  COUNT(cu.user_id),
  MAX(p.birthday)
  FROM communities_users cu
    JOIN communities c 
      ON cu.community_id = c.id
    JOIN profiles p 
      ON cu.user_id = p.user_id
  GROUP BY name
  ORDER BY name;
 
 -- получили все неодходимые данные для выполнения задания, производим вычисления
 
 
 SELECT c.name,
  (SELECT COUNT(user_id) FROM communities_users) / (SELECT COUNT(name) FROM communities) AS average,
  MAX(p.birthday) AS youngest,
  MIN(p.birthday) AS the_oldest,
  COUNT(cu.user_id) AS total_by_group,
  (SELECT COUNT(user_id) FROM communities_users) AS total,
  COUNT(cu.user_id) / (SELECT COUNT(user_id) FROM communities_users) * 100 AS '%%'
  FROM communities_users cu
    JOIN communities c 
      ON cu.community_id = c.id
    JOIN profiles p 
      ON cu.user_id = p.user_id
  GROUP BY name
  ORDER BY name;
 
 -- применяем оконные функции
 -- так и не понял как получить кол-во строк в выборке, а именно количество групп для подсчета среднего значения
SET @groups := (SELECT COUNT(*) FROM communities);
SELECT @groups;
 
SELECT DISTINCT c.name,
  COUNT(cu.user_id) OVER() / @groups AS average, -- в таком варианте COUNT(cu.user_id) OVER() / COUNT(c.name) OVER() знаменатель получается равным числителю, DISTINCT не работает
  MAX(p.birthday) OVER w AS youngest,
  MIN(p.birthday) OVER w AS the_oldest,
  COUNT(cu.user_id) OVER w AS total_by_group,
  COUNT(cu.user_id) OVER() AS total,
  COUNT(cu.user_id) OVER w / COUNT(cu.user_id) OVER() * 100 AS '%%'
  FROM communities_users cu
    JOIN communities c 
      ON cu.community_id = c.id
    JOIN profiles p 
      ON cu.user_id = p.user_id
      WINDOW w AS (PARTITION BY c.name);
     
 -- 3. (по желанию) Задание на денормализацию
-- Разобраться как построен и работает следующий запрос:
-- Найти 10 пользователей, которые проявляют наименьшую активность 
-- в использовании социальной сети.
 -- Правильно-ли он построен?
-- Какие изменения, включая денормализацию, можно внести в структуру БД, чтобы существенно повысить скорость работы этого запроса?

SELECT users.id,
  COUNT(DISTINCT messages.id) +
  COUNT(DISTINCT likes.id) +
  COUNT(DISTINCT media.id) AS activity
   FROM users
     LEFT JOIN messages
       ON users.id = messages.from_user_id
     LEFT JOIN likes
       ON users.id = likes.user_id
     LEFT JOIN media
       ON users.id = media.user_id
   GROUP BY users.id
   ORDER BY activity;
  
-- Выглядит построение запроса правильно (разве что стоит добавить таблицу posts в учет активности), попробовал применить оконные 
-- функции - неверный вывод с DISTINCT они не работают. 
-- Применимы ли вообще окна с внешними соединениями? По изменениям в структуре, стоит наверное включить в таблицу users счетчик активности
-- отдельным столбцом, приращивая его каждым активным действием пользователя.

DESC users;
SELECT * FROM users;

ALTER TABLE users ADD COLUMN activity INT NOT NULL DEFAULT 0;

-- создадим триггеры приращения для messages
DESC messages;
SELECT * FROM messages;

DELIMITER //

CREATE TRIGGER user_activity_message_increment AFTER INSERT ON messages
FOR EACH ROW BEGIN
	UPDATE users SET activity = activity + 1 
	  WHERE NEW.from_user_id = users.id;
END //

DELIMITER ;

-- проверим работу триггера, внеся строку в сообщения

INSERT INTO messages(from_user_id, to_user_id, body) VALUES
 (1, 100, 'sometext');

-- для likes
DESC likes;
SELECT * FROM likes;

DELIMITER //

CREATE TRIGGER user_activity_likes_increment AFTER INSERT ON likes
FOR EACH ROW BEGIN
	UPDATE users SET activity = activity + 1 
	  WHERE NEW.user_id = users.id;
END //

DELIMITER ;

-- проверка
INSERT INTO likes(user_id, target_id, target_type_id) VALUES
 (1, 100, 3);
 
-- для media
DESC media;
SELECT * FROM media;

DELIMITER //

CREATE TRIGGER user_activity_media_increment AFTER INSERT ON media
FOR EACH ROW BEGIN
	UPDATE users SET activity = activity + 1 
	  WHERE NEW.user_id = users.id;
END //

DELIMITER ;

-- проверка
INSERT INTO media(user_id, filename, media_type_id) VALUES
 (1, 'https://www.youtube.com/watch?v=GH9JG4VtnDM', 2);
 
