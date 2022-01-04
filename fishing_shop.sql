-- Данные для Интернет-магазина рыболовных товаров.

DROP DATABASE IF EXISTS fishing_shop;

CREATE DATABASE fishing_shop;

USE fishing_shop;

-- 1. Создаем таблицу с товарами. 
DROP TABLE IF EXISTS products;

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товары';

INSERT INTO products (name, description, price, catalog_id) VALUES
  ('Maps', 'Блесна вращающаяся с лепестком № 3, красным оперением.', 599.00, 1),
  ('Konger', 'Блесна колеблющаяся медного цвета с крупным тройником', 399.00, 1),
  ('MisterTwister', 'Твистер ароматизированный на крупного хищника.', 100.00, 1),
  ('Vibro', 'Виброхвост для мелкого окуня.', 150.00, 1),
  ('Owner', 'Крючок из закаленной стали с ушком.', 199.00, 2),
  ('PopLine', 'Флюрокарбоновая леска универсальная.', 799.00, 2),
  ('Cargo', 'Грузло каплевидное.', 99.00, 2),
  ('Briscola', 'Удилище фидерное 3,6 м.', 9999.00, 3),
  ('Catch', 'Поплавок с длинным килем для течения.', 299.00, 2),
  ('Feeder', 'Кормушка утяжеленная для сильного течения.', 182.00, 3);

SELECT * FROM products; 
 
-- 2. Создаем таблицу с каталогами товаров. 
DROP TABLE IF EXISTS catalogs;

CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Каталоги товаров';

INSERT INTO catalogs VALUES
  (NULL, 'Удилища'),
  (NULL, 'Катушки'),
  (NULL, 'Лески'),
  (NULL, 'Чехлы'),
  (NULL, 'Поплавки'),
  (NULL, 'Грузила'),
  (NULL, 'Крючки'),
  (NULL, 'Кормушки'),
  (NULL, 'Садки'),
  (NULL, 'Подставки');

SELECT * FROM catalogs;

-- 3. Создаем таблицу с разделами на сайте. 
DROP TABLE IF EXISTS rubrics;

CREATE TABLE rubrics (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела'
) COMMENT = 'Разделы Интернет-магазина';

INSERT INTO rubrics VALUES
  (NULL, 'Главная'),
  (NULL, 'О компании'),
  (NULL, 'Новости'),
  (NULL, 'Консультация'),
  (NULL, 'Как купить'),
  (NULL, 'Доставка'),
  (NULL, 'Оплата'),
  (NULL, 'Скидки и акции'),
  (NULL, 'Контакты'),
  (NULL, 'Отзывы');

SELECT * FROM rubrics; 

-- 4. Создаем таблицу с покупателями. 
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX (name)
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29'),
  ('Николай', '1984-07-04'),
  ('Анатолий', '1986-04-24'),
  ('Дмитрий', '1988-10-23'),
  ('Гор', '1989-12-08');
  
 SELECT * FROM users; 
 
-- 5. Создаем таблицу с профилями зарегистрировавшихся покупателей. 
DROP TABLE IF EXISTS profiles;

CREATE TABLE profiles (
	user_id SERIAL PRIMARY KEY,
	gender ENUM('f', 'm', 'x') NOT NULL,
	photo_id BIGINT UNSIGNED NOT NULL,
	city VARCHAR(130),
	country VARCHAR(130),
	FOREIGN KEY (user_id) REFERENCES users (id)
) COMMENT = 'Профили зарегистрированных покупателей';

INSERT INTO profiles (gender, photo_id, city, country) VALUES
  ('m', 1, 'Москва', 'Россия'),
  ('f', 1, 'Киев', 'Украина'),
  ('m', 2, 'Минск', 'Беларусь'),
  ('m', 2, 'Тула', 'Россия'),
  ('m', 3, 'Николаев', 'Украина'),
  ('f', 3, 'Брест', 'Беларусь'),
  ('m', 4, 'Новомосковск', 'Россия'),
  ('m', 4, 'Рославль', 'Россия'),
  ('m', 5, 'Венев', 'Россия'),
  ('m', 5, 'Тула', 'Россия');
  
SELECT * FROM profiles;
 
-- 6. Создаем таблицу с заказами покупателей. 
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id (user_id)
) COMMENT = 'Заказы';

INSERT INTO orders (user_id) VALUES 
  (1),
  (2),
  (3),
  (4),
  (5),
  (6),
  (7),
  (8),
  (9),
  (10);
  
SELECT * FROM orders;

-- 7. Создаем таблицу с составами заказов. 
DROP TABLE IF EXISTS orders_products;

CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id INT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Состав заказа';

INSERT INTO orders_products (order_id, product_id, total) VALUES
  (1, 1, 1),
  (2, 2, 2),
  (3, 3, 3),
  (4, 4, 4),
  (5, 5, 5),
  (6, 6, 6),
  (7, 7, 7),
  (8, 8, 8),
  (9, 9, 9),
  (10, 10, 10); 

SELECT * FROM orders_products;

-- 8. Создаем таблицу со скидками. 
DROP TABLE IF EXISTS discounts;

CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  product_id INT UNSIGNED,
  discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATE,
  finished_at DATE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id (user_id),
  KEY index_of_product_id (product_id)
) COMMENT = 'Скидки';

INSERT INTO discounts (user_id, product_id, discount, started_at, finished_at) VALUES
  (1, 1, 0.1, '2022-01-01', '2022-01-09'),
  (2, 2, 0.2, '2022-01-01', '2022-01-09'),
  (3, 3, 0.3, '2022-01-01', '2022-01-09'),
  (4, 4, 0.4, '2022-01-01', '2022-01-09'),
  (5, 5, 0.5, '2022-01-01', '2022-01-09'),
  (6, 6, 0.5, '2022-01-01', '2022-01-09'),
  (7, 7, 0.4, '2022-01-01', '2022-01-09'),
  (8, 8, 0.3, '2022-01-01', '2022-01-09'),
  (9, 9, 0.2, '2022-01-01', '2022-01-09'),
  (10, 10, 0.1, '2022-01-01', '2022-01-09');
  
SELECT * FROM discounts;

-- 9. Создаем таблицу с методом оплаты (наличными курьеры или иными).
DROP TABLE IF EXISTS cash;

CREATE TABLE cash (
  id SERIAL PRIMARY KEY,
  is_cash BOOLEAN DEFAULT TRUE,
  how_much DECIMAL (15,2),
  payment_at DATETIME DEFAULT NOW()
) COMMENT = 'Метод оплаты и сумма';

INSERT INTO cash VALUES 
  (DEFAULT, DEFAULT, 10000.00, DEFAULT),
  (DEFAULT, DEFAULT, 12000.00, DEFAULT),
  (DEFAULT, DEFAULT, 15000.00, DEFAULT),
  (DEFAULT, DEFAULT, 17000.00, DEFAULT),
  (DEFAULT, DEFAULT, 5000.00, DEFAULT),
  (DEFAULT, DEFAULT, 9000.00, DEFAULT),
  (DEFAULT, DEFAULT, 50000.00, DEFAULT),
  (DEFAULT, DEFAULT, 6000.00, DEFAULT),
  (DEFAULT, DEFAULT, 10000.00, DEFAULT),
  (DEFAULT, DEFAULT, 13000.00, DEFAULT);
 
SELECT * FROM cash;
 
-- 10. Создаем таблицу с отзывами о товарах. 
DROP TABLE IF EXISTS feedback;

CREATE TABLE feedback (
  id SERIAL PRIMARY KEY,
  from_user_id BIGINT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (from_user_id) REFERENCES users (id),
  INDEX(from_user_id)
) COMMENT = 'Отзывы покупателей';

INSERT INTO feedback VALUES
  (DEFAULT, 1, 'Спасибо! Пятерка!', DEFAULT, DEFAULT),
  (DEFAULT, 2, 'Нормально! Четверочка!', DEFAULT, DEFAULT),
  (DEFAULT, 3, 'Ну, такое. На три.', DEFAULT, DEFAULT),
  (DEFAULT, 4, 'Ужасно! Двойка!', DEFAULT, DEFAULT),
  (DEFAULT, 5, 'Фу. Больше никогда сюда не вернусь!', DEFAULT, DEFAULT),
  (DEFAULT, 6, 'Спасибо! Блесна отличная!', DEFAULT, DEFAULT),
  (DEFAULT, 7, 'Круто! Можно оплатить курьеру наличкой!', DEFAULT, DEFAULT),
  (DEFAULT, 8, 'Можно и получше дизайн запилить.', DEFAULT, DEFAULT),
  (DEFAULT, 9, 'Спасибо! Сын счастлив!', DEFAULT, DEFAULT),
  (DEFAULT, 10, 'С НОВЫМ ГОДОМ И РОЖДЕСТВОМ ХРИСТОВЫМ', DEFAULT, DEFAULT);
  
 SELECT * FROM feedback;