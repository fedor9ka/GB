-- 1. Создать все необходимые внешние ключи и диаграмму отношений.

ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;

ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id);
   
DESC communities_users;

ALTER TABLE communities_users
  ADD CONSTRAINT communities_users_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT communities_users_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id);
 
DESC friendship;
 
ALTER TABLE friendship
  ADD CONSTRAINT friendship_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_friend_id_fk
    FOREIGN KEY (friend_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_status_id_fk
    FOREIGN KEY (status_id) REFERENCES friendsip_statuses(id);
   
DESC media;

ALTER TABLE media
  ADD CONSTRAINT media_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT media_media_type_id_fk 
    FOREIGN KEY (media_type_id) REFERENCES media_types(id);
 
DESC likes;

ALTER TABLE likes
  ADD CONSTRAINT likes_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT likes_target_type_id_fk 
    FOREIGN KEY (target_type_id) REFERENCES target_types(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT likes_target_id_fk_users 
    FOREIGN KEY (target_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT likes_target_id_fk_messages
    FOREIGN KEY (target_id) REFERENCES messages(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT likes_target_id_fk_media
    FOREIGN KEY (target_id) REFERENCES media(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT likes_target_id_fk_posts
    FOREIGN KEY (target_id) REFERENCES posts(id)
      ON DELETE CASCADE;
 
DESC posts;
 
ALTER TABLE posts
  ADD CONSTRAINT posts_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT posts_community_id_fk
    FOREIGN KEY (community_id) REFERENCES communities(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT posts_media_id_fk 
   FOREIGN KEY (media_id) REFERENCES media(id)
     ON DELETE CASCADE;

-- 2. Создать и заполнить таблицы лайков и постов.

-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  user_id INT UNSIGNED NOT NULL COMMENT "Автор лайка",
  target_id INT UNSIGNED NOT NULL COMMENT "Указывает на конкретную строку, которой лайк поставлен",
  target_type_id INT UNSIGNED NOT NULL COMMENT "Определяет таблицу, где находится строка target_id",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');
 
 -- Заполняем лайки
INSERT INTO likes 
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 150)), 
    FLOOR(1 + (RAND() * 150)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;

-- Создадим таблицу постов
DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  user_id INT UNSIGNED NOT NULL COMMENT "Автор поста",
  community_id INT UNSIGNED COMMENT "Пост может принадлежать community",
  head VARCHAR(255) COMMENT "Заголовок",
  body TEXT NOT NULL COMMENT "Тело",
  media_id INT UNSIGNED COMMENT "Приложенный медиафайл",
  is_public BOOLEAN DEFAULT TRUE COMMENT "Флаг публичный",
  is_archived BOOLEAN DEFAULT FALSE COMMENT "Флог заархивированный",
  views_counter INT UNSIGNED DEFAULT 0 COMMENT "Заголовок",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Количество просмотров",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- заполнил фейкером данные в таблицу posts, получил заполненные столбцы как user_id, так и community_id, но пост принадлежит либо user либо community    
DESC posts;

SELECT * FROM posts LIMIT 25;

ALTER TABLE posts MODIFY COLUMN user_id INT UNSIGNED; -- user_id было NOT NULL

CREATE TEMPORARY TABLE communities_temp (id INT);

INSERT INTO communities_temp VALUES
  ('1'),
  ('2'),
  ('3'),
  ('4'),
  ('5'),
  ('6'),
  (NULL),
  (NULL),
  (NULL);

UPDATE posts SET community_id = (SELECT id FROM communities_temp ORDER BY RAND() LIMIT 1); -- заполнил community_id случайными значениями с NULL из временной таблицы

UPDATE posts SET user_id = NULL WHERE community_id > 0; -- в замисимости от значения community_id проставил NULL в user_id

-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?

DESC likes;

SELECT COUNT(*) AS total,
 (SELECT gender FROM profiles WHERE user_id = likes.user_id) AS gender
 FROM likes
 GROUP BY gender;

-- 4. Подсчитать общее количество лайков десяти самым молодым пользователям (сколько лайков получили 10 самых молодых пользователей).

DESC likes;

SELECT * FROM likes;

DESC profiles;

SELECT target_id FROM likes 
  WHERE target_type_id = 
   (SELECT id FROM target_types WHERE name = 'users'); -- выборка лайков пользователям, но значения все равно принадлежат таблице media, подскажите как исправить, пожалуйста.


SELECT * FROM (SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10) AS youngests; -- 10 самых молодых пользователей

SELECT COUNT(*) FROM likes
  WHERE target_type_id = (SELECT id FROM target_types WHERE name = 'users')
  AND target_id IN (SELECT * FROM (SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10) AS youngests); -- решение
  
-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
-- (критерии активности необходимо определить самостоятельно).
-- Критерии активности: количество сообщений, количество лайков, количество постов.

DESC messages;
SELECT * FROM messages;

DESC likes;

DESC posts;
SELECT * FROM posts;

SELECT from_user_id, COUNT(*) as total_messages FROM messages GROUP BY from_user_id; -- количество сообщений, написанных пользователем

SELECT user_id , COUNT(*) as total_likes FROM likes GROUP BY user_id; -- количество лайков, поставленных пользователем

SELECT user_id , COUNT(*) as total_posts FROM posts GROUP BY user_id; -- количество постов, опубликованных пользователем

SELECT id,
  IF(id IN (SELECT from_user_id FROM messages), (SELECT COUNT(*) FROM messages WHERE from_user_id = users.id GROUP BY from_user_id), 0) AS total_messages
  FROM users
  ORDER BY total_messages
  LIMIT 10;                                                           -- наименьшая активность по критерию "сообщения"

SELECT id,
  IF(id IN (SELECT user_id FROM likes), (SELECT COUNT(*) FROM likes WHERE user_id = users.id GROUP BY user_id), 0) AS total_likes
  FROM users
  ORDER BY total_likes
  LIMIT 10;                                                           -- наименьшая активность по критерию "лайки"

SELECT id,
  IF(id IN (SELECT user_id FROM posts), (SELECT COUNT(*) FROM posts WHERE user_id = users.id GROUP BY user_id), 0) AS total_posts
  FROM users
  ORDER BY total_posts
  LIMIT 10;                                                           -- наименьшая активность по критерию "посты"
  
-- объединяем данные через UNION

 SELECT * FROM
    (SELECT id,
      IF(id IN (SELECT from_user_id FROM messages), (SELECT COUNT(*) FROM messages WHERE from_user_id = users.id GROUP BY from_user_id), 0) AS total
        FROM users
          ORDER BY total
            LIMIT 10) AS total_messages
UNION ALL 
  SELECT * FROM
    (SELECT id,
      IF(id IN (SELECT user_id FROM likes), (SELECT COUNT(*) FROM likes WHERE user_id = users.id GROUP BY user_id), 0) AS total
        FROM users
          ORDER BY total
            LIMIT 10) AS total_likes
UNION ALL
  SELECT * FROM
    (SELECT id,
      IF(id IN (SELECT user_id FROM posts), (SELECT COUNT(*) FROM posts WHERE user_id = users.id GROUP BY user_id), 0) AS total
        FROM users
          ORDER BY total
            LIMIT 10) AS total_posts; -- получили общую таблицу по минимальным действия пользователя, могут повторяться id, нужно суммировать и отсортировать
            
SELECT id,
  SUM(total) AS total_activity
    FROM ( 
    SELECT * FROM
    (SELECT id,
      IF(id IN (SELECT from_user_id FROM messages), (SELECT COUNT(*) FROM messages WHERE from_user_id = users.id GROUP BY from_user_id), 0) AS total
        FROM users
          ORDER BY total
            LIMIT 10) AS total_messages
UNION ALL 
  SELECT * FROM
    (SELECT id,
      IF(id IN (SELECT user_id FROM likes), (SELECT COUNT(*) FROM likes WHERE user_id = users.id GROUP BY user_id), 0) AS total
        FROM users
          ORDER BY total
            LIMIT 10) AS total_likes
UNION ALL
  SELECT * FROM
    (SELECT id,
      IF(id IN (SELECT user_id FROM posts), (SELECT COUNT(*) FROM posts WHERE user_id = users.id GROUP BY user_id), 0) AS total
        FROM users
          ORDER BY total
            LIMIT 10) AS total_posts
    ) AS final_table
  GROUP BY id
    ORDER BY total_activity
      LIMIT 10;


  