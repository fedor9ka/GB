
-- ������������ ������� �� ���� ����������, ����������, ���������� � �����������
-- 1.	����� � ������� users ���� created_at � updated_at ��������� ��������������. ��������� �� �������� ����� � ��������.

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
  ('��������', NULL, NULL),
  ('�������', NULL, NULL),
  ('�������', NULL, NULL),
  ('�������', NULL, NULL),

UPDATE users SET created_at = NOW(), updated_at = NOW();

-- 2.	������� users ���� �������� ��������������. ������ created_at � updated_at ���� ������ ����� VARCHAR � � ��� ������ ����� ���������� �������� � ������� 20.10.2017 8:10. 
--      ���������� ������������� ���� � ���� DATETIME, �������� �������� ����� ��������.

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

-- 3.	� ������� ��������� ������� storehouses_products � ���� value ����� ����������� ����� ������ �����: 0, ���� ����� ���������� � ���� ����, ���� �� ������ ������� ������.
-- ���������� ������������� ������ ����� �������, ����� ��� ���������� � ������� ���������� �������� value. ������ ������� ������ ������ ���������� � �����, ����� ���� �������.

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


-- ������������ ������� ���� ���������� �������
-- 1.	����������� ������� ������� ������������� � ������� users.

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

-- 2.	����������� ���������� ���� ��������, ������� ���������� �� ������ �� ���� ������. ������� ������, ��� ���������� ��� ������ �������� ����, � �� ���� ��������.

-- �� ����������






