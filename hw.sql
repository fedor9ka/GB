
-- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT * FROM likes ORDER BY target_id;
SELECT * FROM profiles p;

SELECT gender, COUNT(gender) as total
  FROM likes
    LEFT JOIN profiles
      ON likes.user_id = profiles.user_id
  GROUP BY gender;
  
-- Подсчитать общее количество лайков десяти самым молодым пользователям (сколько лайков получили 10 самых молодых пользователей).

-- Вариант с подсчетом лайков именно пользователю

SELECT DISTINCT likes.id, profiles.user_id, target_id, birthday, target_type_id
  FROM profiles
    LEFT JOIN likes
      ON profiles.user_id = likes.target_id
        AND target_type_id = 2
  ORDER BY birthday DESC;
  

-- Подбиваем сумму внешним запросом
SELECT SUM(total_likes) FROM
  (SELECT DISTINCT profiles.user_id, target_id, birthday, COUNT(target_type_id) AS total_likes
  FROM profiles
    LEFT JOIN likes
      ON profiles.user_id = likes.target_id
        AND target_type_id = 2
  GROUP BY profiles.user_id
  ORDER BY birthday DESC
  LIMIT 10) AS user_likes;
 
 -- Проверка
 
 SELECT COUNT(*) FROM likes 
  WHERE target_type_id = 2
    AND target_id IN (SELECT * FROM (
      SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10
    ) AS sorted_profiles ) 
;

--  Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
-- критерии активности: лайки, медиа, сообщения, посты

 SELECT CONCAT(first_name, ' ', last_name) AS user, 
   COUNT(DISTINCT(likes.id)) + 
   COUNT(DISTINCT(media.id)) + 
   COUNT(DISTINCT(messages.id)) + 
   COUNT(DISTINCT(posts.id)) AS overall_activity
   FROM users
     LEFT JOIN likes 
       ON users.id = likes.user_id
     LEFT JOIN media
       ON users.id = media.user_id 
     LEFT JOIN messages
       ON users.id = messages.from_user_id 
     LEFT JOIN posts
       ON users.id = posts.user_id 
   GROUP BY users.id
   ORDER BY overall_activity -- DESC
   LIMIT 10;

-- проверка (из прошлого ДЗ), лучше смотреть с DESC от максимального  
SELECT 
  CONCAT(first_name, ' ', last_name) AS user,
	(SELECT COUNT(*) FROM likes WHERE likes.user_id = users.id) + 
	(SELECT COUNT(*) FROM media WHERE media.user_id = users.id) + 
	(SELECT COUNT(*) FROM messages WHERE messages.from_user_id = users.id) +
	(SELECT COUNT(*) FROM posts WHERE posts.user_id = users.id) AS overall_activity 
	  FROM users
	  ORDER BY overall_activity DESC
	  LIMIT 10;
