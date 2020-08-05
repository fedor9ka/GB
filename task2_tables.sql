-- скрипты создания структуры БД (с первичными ключами, индексами, внешними ключами);
CREATE DATABASE airbnb;
USE airbnb;

DROP TABLE IF EXISTS users;
CREATE TABLE users(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Идентификатор строки',
  first_name VARCHAR(100) NOT NULL COMMENT 'Имя пользователя',
  last_name VARCHAR(100) NOT NULL COMMENT 'Фамилия пользователя',
  email VARCHAR(60) NOT NULL UNIQUE COMMENT 'Почта',
  phone VARCHAR(60) NOT NULL UNIQUE COMMENT 'Телефон',
  is_owner BOOL COMMENT 'Флаг собственника',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время обновления строки'
) COMMENT 'Пользователи';

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles(
  user_id INT UNSIGNED NOT NULL PRIMARY KEY COMMENT 'Ссылка на пользователя',
  photo_id INT UNSIGNED UNIQUE COMMENT 'Ссылка на основную фотографию пользователя',
  gender ENUM('m', 'w') NOT NULL COMMENT 'Пол',
  birthday DATE NOT NULL COMMENT 'Дата рождения',
  country_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на страну',
  city_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на город',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время обновления строки'
) COMMENT 'Профили';

DROP TABLE IF EXISTS owners;
CREATE TABLE owners(
  id INT UNSIGNED NOT NULL COMMENT 'Идентификатор строки',
  user_id INT UNSIGNED NOT NULL PRIMARY KEY COMMENT 'Ссылка на пользователя',
  super_owner BOOL COMMENT 'Флаг суперхозяина',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время обновления строки'
) COMMENT 'Собственники жилья';

-- на тестовых данных полного списка справочников стран и городов не будет, тем не менее они вынесены в отдельные таблицы, 
-- так как в реальном приложении их довольно много и они участвуют в большинстве запросов
DROP TABLE IF EXISTS countries;
CREATE TABLE countries(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Идентификатор строки',
  country_name VARCHAR(60) UNIQUE COMMENT 'Название страны',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки'
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Идентификатор строки',
  city_name VARCHAR(100) COMMENT 'Название города',
  country_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на страну',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки'
)COMMENT 'Города';

DROP TABLE IF EXISTS property;
CREATE TABLE property(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Идентификатор строки',
  owner_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на собственника жилья',
  country_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на страну',
  city_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на город',
  address VARCHAR(250) COMMENT 'Адрес',
  title VARCHAR(50) COMMENT 'Название объекта',
  description VARCHAR(500) COMMENT 'Описание',
  accomodation ENUM('Жилье целиком', 'Отдельная комната', 'Место в комнате'),
  property_type ENUM('Квартира', 'Дом', 'Уникальное жилье'),
  capacity TINYINT COMMENT 'Вместимость',
  -- facilities_id 
  price DECIMAL (11,2) UNSIGNED NOT NULL COMMENT 'Стоимость одного дня',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время обновления строки'
) COMMENT 'Объекты размещения';

DROP TABLE IF EXISTS photos;
CREATE TABLE photos(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Идентификатор строки',
  user_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на пользователя, который загрузил файл',
  filename VARCHAR(255) NOT NULL COMMENT 'Путь к файлу',
  `size` INT NOT NULL COMMENT 'Размер файла',
  metadata JSON COMMENT 'Метаданные файла',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время обновления строки'
) COMMENT 'Фотографии';

DROP TABLE IF EXISTS property_photos;
CREATE TABLE property_photos(
  property_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на объект размещения',
  photo_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на фотографию',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  PRIMARY KEY (property_id, photo_id) COMMENT 'Составной первичный ключ'
) COMMENT 'Фотографии жилья';

DROP TABLE IF EXISTS bookings;
CREATE TABLE bookings(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Идентификатор строки',
  user_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на пользователя, забронировавшего объект',
  property_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на объект размещения',
  start_date DATE NOT NULL COMMENT 'Дата начала бронирования',
  end_date DATE NOT NULL COMMENT 'Дата окончания бронирования',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время обновления строки'
) COMMENT 'Бронирования';


DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Идентификатор строки',
  user_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на пользователя, который оставил отзыв',
  body VARCHAR(1200) COMMENT 'Текст отзыва',
  rating ENUM('1', '2', '3', '4', '5') COMMENT 'Оценка',
  target_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на конкретную строку, которой был оставлен отзыв',
  target_type ENUM('Гость', 'Объект размещения') COMMENT 'Кому был оставлен отзыв',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки'
) COMMENT 'Отзывы';


DROP TABLE IF EXISTS messages;
CREATE TABLE messages(
  id INT UNSIGNED UNIQUE NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'Идентификатор строки', 
  from_user_id INT UNSIGNED NOT NULL COMMENT 'Отправитель сообщения',
  to_user_id INT UNSIGNED NOT NULL COMMENT 'Получатель сообщения',
  body VARCHAR(2500) NOT NULL COMMENT 'Текст',
  is_delivered BOOLEAN COMMENT 'Признак доставки',
  created_at DATETIME DEFAULT NOW() COMMENT 'Время создания строки',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время обновления строки'
) COMMENT 'Сообщения';

-- внешние ключи (сначала заполнил БД данными, правил (task5), только потом добавил внешие ключи и индексы)

SHOW TABLES;
DESC profiles;

ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES photos(id),
  ADD CONSTRAINT profiles_country_id_fk
    FOREIGN KEY (country_id) REFERENCES countries(id),
  ADD CONSTRAINT profiles_city_id_fk
    FOREIGN KEY (city_id) REFERENCES cities(id);
   
DESC owners;

ALTER TABLE owners
  ADD CONSTRAINT owners_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id);

DESC cities;

ALTER TABLE cities
  ADD CONSTRAINT cities_country_id_fk
    FOREIGN KEY (country_id) REFERENCES countries(id);
    
DESC property;

ALTER TABLE property
  ADD CONSTRAINT property_owner_id_fk
    FOREIGN KEY (owner_id) REFERENCES owners(user_id),
  ADD CONSTRAINT property_country_id_fk
    FOREIGN KEY (country_id) REFERENCES countries(id),
  ADD CONSTRAINT property_city_id_fk
    FOREIGN KEY (city_id) REFERENCES cities(id);
    
DESC photos;

ALTER TABLE photos
  ADD CONSTRAINT photos_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id);
    
DESC property_photos;

ALTER TABLE property_photos
  ADD CONSTRAINT property_photos_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES photos(id),
  ADD CONSTRAINT property_photos_property_id_fk
    FOREIGN KEY (property_id) REFERENCES property(id);
   
DESC bookings;

ALTER TABLE bookings
  ADD CONSTRAINT bookings_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT bookings_property_id_fk
    FOREIGN KEY (property_id) REFERENCES property(id);

DESC reviews;

ALTER TABLE reviews
  ADD CONSTRAINT reviews_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id);
   
DESC messages;

ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk
    FOREIGN KEY (to_user_id) REFERENCES users(id);

-- индексы
-- Запросы на выборку данных по городам

DESC cities;
SHOW INDEX FROM cities;

CREATE INDEX cities_city_name_idx
  ON cities(city_name);
 
-- Запросы на формирование сообщений, составной индекс

DESC messages;
SHOW INDEX FROM messages;

CREATE INDEX messages_from_user_id_to_user_id_idx 
  ON messages (from_user_id, to_user_id);
  
