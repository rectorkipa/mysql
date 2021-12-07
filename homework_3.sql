DROP DATABASE IF EXISTS vk;

CREATE DATABASE IF NOT EXISTS vk;

SHOW DATABASES;

-- используем БД vk
# comment


USE vk;

/*
 * 1. Создадим таблицу users.
*/
/*
 * Таблица с пользователями.
 * 
 * Сценарий: Необходимо хранить данные зарегестрированных пользователей.
 * 
 * Что есть у пользователей: айди - уникальный идентификатор пользователя,
 * имя, фамилия, телефон, почта.
 * 
 * Так как у нас есть айди - он становится primary key. У каждой хорошо построенной таблицы
 * должен быть primary key. Он ускоряет поиск по значению и гарантирует, что все значения в колонке
 * уникальны.
 * Также айди автоматически инкрементируется, будет принимать значения (1,2,3,...)
 * 
 * Хотим, чтобы пользователь при регистрации обязательно заполнял все эти данные.
 * Тогда добавляем к определению колонки NOT NULL.
 * 
 * Хотим также хранить пароль (хэш-пароля), и чтобы у пользователя была возможность не задавать 
 * пароль при регистрации.
 * Добавляем к определению колонки password_hash DEFAULT NULL.
 * 
 * Хотим также хранить дату и время регистрации пользователя.
 * Добавляем колонку created_at, которой по дефолту ставится текущая дата и время благодаря
 * DEFAULT CURRENT_TIMESTAMP.
 * 
 * Также мы хотим, чтобы почта и телефон пользователя при регистрации были уникальными.
 * То есть, чтобы пользователь не мог зарегестрировать под одним номером телефона или почтой
 * два аккаунта.
 * Либо используем в определении колонки UNIQUE,
 * Либо создаем UNIQUE INDEX по каждой из колонок.
 * 
 * INDEX отвечает за быстрый поиск. Самый быстрый поиск - по primary key. Но primary key может быть
 * только один в таблице.
 * 
 * Когда используется индекс?
 * Когда мы часто ищем какую-то информацию для значения, которое участвует в индексе.
 * Например, мы ищем имя пользователя, зная его email (это будет частый запрос в БД).
 * По email есть индекс, значит поиск произойдет быстрее.
 * 
 * Уникальный индекс - тот же самый индекс, который дополнительно гарантирует, что все значения в колонке уникальны.
 * 
 * Злоупотреблять индексами нельзя. Много индексов - медленно работают запросы.
 * 
 */
CREATE TABLE users(
	id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	firstname VARCHAR(50) NOT NULL,
	lastname VARCHAR(50) NOT NULL,
	phone CHAR(11) NOT NULL,
	email VARCHAR(120) UNIQUE,
	password_hash CHAR(65),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX (lastname),
	INDEX (phone)
);

-- показываем все таблицы
SHOW TABLES;

INSERT INTO users 
VALUES (1, 'Petya', 'Petukhov','99999999929', 'petya@mail.com', '81dc9bdb52d04dc20036dbd8313ed055', DEFAULT, DEFAULT);

SELECT * FROM users;

INSERT INTO users (firstname, lastname, email, password_hash, phone) 
 VALUES ('Vasya', 'Vasilkov', 'vasya@mail.com', '81dc9bdb52d04dc20036dbd8313ed055', '99999999919');
 
/*
 * 2. Создадим таблицу с профилем пользователя, чтобы не хранить все данные в таблице users
 * 
 * Сценарий: Необходимо хранить личную информацию пользователей в отдельной таблице.
 * 
 * Какая личная информация нам нужна: пол, возраст, фотография, город, страна.
 * Но как связать пользователя с его личной информацией?
 * 
 * Мы можем сделать это с помощью ссылки на таблицу users. То есть ссылки на конкретного
 * пользователя в таблице users.
 *
 * Например, у Пети id = 1 в таблице users. В таблице profiles мы делаем запись с user_id = 1
 * и можем гарантировать, что в этой записи содержится личная информация Пети. То есть, user_id = 1
 * говорит нам о том, что в записи содержится информация именно для пользователя из таблицы users с 
 * id = 1 и ни для кого другого.
 * 
 * Для связи между таблицами создается foreign key. Он гарантирует, что для каждого user_id существует
 * id в таблице profiles. А также то, что не существует user_id, которому не соответсвует никакой id в users.
 * FOREIGN KEY (user_id) REFERENCES users (id)
 * 
 * Одному пользователю соответствует один профиль. Связь один к одному.
 * 
*/

CREATE TABLE profiles(
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	gender ENUM('f', 'm', 'x') NOT NULL,
	birthday DATE NOT NULL,
	photo_id BIGINT UNSIGNED NOT NULL,
	city VARCHAR(130),
	country VARCHAR(130),
	FOREIGN KEY (user_id) REFERENCES users (id)
);

-- https://dev.mysql.com/doc/mysql-tutorial-excerpt/8.0/en/example-auto-increment.html

-- Заполним таблицу, добавим профили для уже созданных Пети и Васи
-- профиль Пети

INSERT INTO profiles VALUES (1, 'm', '1997-12-01', 1, 'Moscow', 'Russia');

SELECT * FROM profiles;

-- профиль Васи
INSERT INTO profiles VALUES (2, 'm', '1988-11-02', 2, 'Moscow', 'Russia');

-- ошибка 
-- INSERT INTO profiles VALUES (8, 'm', '1988-11-02', 2, 'Moscow', 'Russia');

/*
 * 3. Создадим таблицу с сообщениями пользователей.
 * 
 * Сценарий: Петя отправляет Васе личное сообщение.
 * 
 * Петя может написать сообщения Васе, Сереже, Грише, а Вася может написать также сообщения Пете, Сереже, Грише.
 * Это связь от многих (пользователей) к многим (пользователям).
 * 
 * Что нам необходимо хранить для сообщения? Отправителя сообщения, получателя сообщения, текст сообщения,
 * дату и время создания сообщения и дату и время обновления сообщения. Также можно хранить информацию о том,
 * прочитано ли сообщение.
 * 
 * Отправитель сообщения - это наш Петя. Когда мы смотрим на сообщение в Вконтакте мы видим имя и фамилию отправителя.
 * Нужно ли нам хранить имя и фамилию отправителя в таблице сообщений?
 * Нет, эта информация уже хранится в таблице users, ее нет необходимости дублировать.
 * Мы можем хранить ссылку на отправителя сообщения, Петю из таблицы users. То есть его id из таблицы users.
 * 
 * Обозначим отправителя сообщения через from_user_id. Значит, в from_user_id мы храним 1, id Пети.
 * С этой 1 мы сможем пойти в таблицу users, найти там запись с id = 1, и достать имя и фамилию Пети.
 * 
 * Аналогично для Васи, создаем поле to_user_id - ссылку на получателя сообщения из таблицы users.
 * Будем хранить в to_user_id 2, иначе - id Васи из таблицы users.
 * 
 * 
 * Нам необходимо определить, нужен ли нам айди сообщения в данной таблице. То есть, нужно ли нам как-то уникально
 * идентифицировать каждое сообщение от Пети к Васе, может ли Петя писать несколько сообщений Васе, необходимо
 * ли нам различать эти сообщения?
 * Да, необходимо.
 * Добавляем id сообщения с авто-инкрементом и primary key.
 * 
 * Для связи отправителя сообщения с таблицей users и получателя сообщения с таблицей users создаем два разных
 * FOREIGN KEY, которые направлены на одну и ту же колонку users id.
 * Отправитель сообщения и получатель могут как совпадать, так и не совпадать для одного сообщения. Foreign key
 * нас никак не ограничивает.
 * 
 * Для быстрого поиска всех сообщений, которые отправил отправитель сообщения с конкретным id (например, ищем
 * все сообщения, которые отправил Петя со своим id = 1) создадим индекс
 * для from_user_id. Он неуникальный, так как отправитель сообщения мог отправить много разных сообщений,
 * он может встречаться в нескольких разных записях как отправитель.
 * 
 * Аналогично для получателя сообщения, to_user_id, чтобы быстро искать все сообщения, которые он получил.
 * (Например, все сообщения, которые получил Вася)
 * 
*/

CREATE TABLE messages (
	id SERIAL PRIMARY KEY, -- BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	is_delivered BOOLEAN DEFAULT FALSE,
	FOREIGN KEY (from_user_id) REFERENCES users (id),
	FOREIGN KEY (to_user_id) REFERENCES users (id)
);

-- Добавим два сообщения от Пети к Васе, одно сообщение от Васи к Пете
INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Hi!', DEFAULT, DEFAULT, DEFAULT);
INSERT INTO messages VALUES (DEFAULT, 1, 2, 'Vasya!', DEFAULT, DEFAULT, DEFAULT);
SELECT * FROM messages;

-- Добавим два сообщения от Пети к Васе, одно сообщение от Васи к Пете
INSERT INTO messages VALUES (DEFAULT, 2, 1, 'Hi, Petya', DEFAULT, DEFAULT, DEFAULT);

/*
 * 4. Создадим таблицу запросов в друзья.
 * 
 * Сценарий: Петя хочет добавить Васю в друзья.
 * 
 * Петя может отправить запросы на дружбу Васе, Сереже, Грише, Вася также может отправить запросы Пете, Сереже, Грише.
 * Это связь от многих (пользователей) к многим (пользователям).
 * 
 * Что нам необходимо хранить для запросов в друзья? Отправителя запроса, получателя запроса,
 * статус запроса (принят или отклонен).
 * 
 * Аналогичная ситуация, которая возникла при создании таблицы messages.
 * Мы отдельно храним ссылку на отправителя запроса, from_user_id, и получателя запроса, to_user_id.
 * 
 * Нам необходимо определить, нужен ли нам айди запроса на дружбу в данной таблице. 
 * То есть, изначально определить, может ли Петя послать несколько запросов на дружбу Васе одновременно?
 * Нет, не может. Петя может отправить Васе только один запрос на дружбу. Идентификатор не нужен.
 * 
 * Однако нам нужно уникально идентифицировать пару отправителя запроса и получателя, чтобы Петя не мог
 * несколько раз отправить запрос на дружбу Васе.
 * Для этого мы можем использовать PRIMARY KEY по двум колонкам, так как он у нас не занят.
 * PRIMARY KEY нам будет гарантировать, что пара (Петя, Вася), где Петя - отправитель, Вася - получатель,
 * будет встречаться в таблице всего один раз.
 * 
 * Аналогично таблице messages добавляем foreign keys и индексы.
 * 
*/
CREATE TABLE friend_requests(
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	accepted BOOL DEFAULT FALSE,
	PRIMARY KEY(from_user_id, to_user_id),
	FOREIGN KEY (from_user_id) REFERENCES users (id),
	FOREIGN KEY (to_user_id) REFERENCES users (id)
);
-- Добавим запрос на дружбу от Пети к Васе
INSERT INTO friend_requests VALUES (1, 2, 1);

SELECT * FROM friend_requests;
/*
 * 5. Создадим таблицу сообществ.
 * 
 * Сценарий: Петя создает сообщество.
 * 
 * Петя может создать много сообществ, однако у сообщества может быть только один создатель.
 * Связь от одного (пользователя) к многим (сообществам).
 * 
 * Что нам необходимо хранить для сообщества? Его айди, название, описание, создателя сообщества.
 * 
 * Создатель сообщества - это пользователь. Значит, по стандартной схеме, мы можем хранить ссылку на пользователя
 * на таблицу users. То есть id пользователя из таблицы users. Сразу же создаем и foreign key.
 * Необходимо запомнить, что при связи от одного к многим ссылка и соответсвенно foreign key создается
 * на стороне многих, то есть сообщества в данном случае.
 * 
 * Добавляем также индекс на создателя сообщества (admin_id) для быстрого поиска всех сообществ, у которых создатель
 * пользователь с конкретным id.
 * 
*/
CREATE TABLE communities(
	id SERIAL,
	name VARCHAR(145) NOT NULL,
	description VARCHAR(255),
	admin_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY(id),
	INDEX communities_name_idx (name),
	CONSTRAINT fk_communities_admin_id FOREIGN KEY (admin_id) REFERENCES users (id)
);

INSERT INTO communities VALUES (DEFAULT, 'Number1', 'I am number one', 1);

/*
 * 6. Создадим таблицу для хранения информации обо всех участниках всех сообществ.
 * 
 * Сценарий: Вася вступил в сообщество Number1.
 * 
 * Вася может вступить во много разных сообществ, при этом в одном сообществе может быть много участников.
 * Связь от многих к многим.
 * 
 * Что нам необходимо хранить? Пользователя, сообщество, в которое он вступил, дату вступления в сообщество.
 * 
 * Так как Вася может вступить в сообщество Number1 только один раз, уникальный идентификатор записи нам не нужен (id),
 * используем спецификацию таблицы friend_requests как макет и создаем по аналогии.
*/
CREATE TABLE communities_users(
	community_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY(community_id, user_id),
	FOREIGN KEY (community_id) REFERENCES communities (id),
	FOREIGN KEY (user_id) REFERENCES users (id)
);

INSERT INTO communities_users VALUES (1, 2);

/*
 * 7. Создадим таблицу для хранения типов медиа файлов, каталог типов медифайлов.
 * 
 * В таблице-каталоге обычно не хранятся ссылки на другие таблицы.
 * В таблице-каталоге обычно хранятся только айди и название, в данном случае айди типа
 * медиа-файла и название медиа-файла.
 * 
 * Аналогичные каталоги можно создать для списка городов, стран, ...
*/
CREATE TABLE media_types(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(45) NOT NULL UNIQUE
);


INSERT INTO media_types VALUES (DEFAULT, 'изображение');
INSERT INTO media_types VALUES (DEFAULT, 'музыка');
INSERT INTO media_types VALUES (DEFAULT, 'документ');


SELECT * FROM media_types;

/*
 * 8. Создадим таблицу всех медиафайлов.
 * 
 * Сценарий: Петя добавляет фотографию.
 * 
 * Петя может добавить много различных медиафайлов, однако у медиафайла может быть только один автор 
 * (тот, кто его добавил).
 * Связь от одного (пользователя) к многим (медиафайлам).
 * 
 * Что нам необходимо хранить для медиафайла? Его айди, создателя, тип, название, размер, дату добавления.
 * 
 * Ссылку на создателя (пользователя) создаем по аналогии с ранее созданными таблицами, добавляем индекс для
 * быстрого поиска медиафайлов пользователя и foreign key.
 * 
 * Также необходимо как-то хранить тип медиа-файла. Можно хранить название типа медиафайла, например, "изображение",
 * "музыка", "документ". Однако, названия типов медиафайлов у нас уже хранятся в нашем каталоге media_types и это будет
 * дублирование данных. Так мы можем хранить не название типа, а ссылку на название типа в каталоге (то есть id типа 
 * медиафайла из таблицы media_types).
 * 
 * У каждого типа медиафайла может быть множество медиафайлов (тип "изображение" может быть у множества медиафайлов),
 * однако у медиафайла может быть только один тип (фотография1 имеет только один тип - "изображение").
 * Так это связь от одного (типа) к многим (медиафайлам).
 * 
 * Создаем колонку media_types_id, где храним id типа из media_types. Создаем foreign key от media_types_id
 * к media_types (id). Индекс не создаем, так как типов медиафайлов будет мало, и индекс будет плохо работать
 * по такой колонке с часто повторяющимися значениями. 
 * 
 * Так в данной таблице у нас получилось две разных связи от одного к многим, которые несвязаны между собой.
*/

-- DROP TABLE media;

CREATE TABLE media (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	media_types_id INT UNSIGNED NOT NULL,
	file_name VARCHAR(255),
	file_size BIGINT UNSIGNED,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (media_types_id) REFERENCES media_types (id)
);
-- Добавим два изображения, которые добавил Петя
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im.jpg', 100, DEFAULT);
INSERT INTO media VALUES (DEFAULT, 1, 1, 'im1.png', 78, DEFAULT);
-- Добавим документ, который добавил Вася
INSERT INTO media VALUES (DEFAULT, 2, 3, 'doc.docx', 1024, DEFAULT);
SELECT * FROM media;

-- Домашняя работа № 3. 

-- 9. Создадим таблицу с денежными переводами от многих (пользователей) к многим (пользователям).

CREATE TABLE money_transfer(
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	amount BIGINT UNSIGNED NOT NULL,
	currency ENUM('RUB', 'USD', 'EUR') NOT NULL,
	sent_at DATETIME DEFAULT NOW(),
	got_at DATETIME DEFAULT NOW(),
	is_delivered BOOLEAN DEFAULT FALSE,
	FOREIGN KEY (from_user_id) REFERENCES users (id),
	FOREIGN KEY (to_user_id) REFERENCES users (id),
	INDEX(from_user_id),
	INDEX(to_user_id)
);

-- Добавим денежный перевод от Пети к Васе:

INSERT INTO money_transfer VALUES (DEFAULT, 1, 2, 182, 'EUR', DEFAULT, DEFAULT, DEFAULT);

SELECT * FROM money_transfer;

-- 10. Создадим таблицу с текстовыми публикациями на стене пользователей.

CREATE TABLE wall_text(
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (from_user_id) REFERENCES users (id),
	FOREIGN KEY (to_user_id) REFERENCES users (id),
	INDEX(from_user_id),
	INDEX(to_user_id)
);

-- Добавим текстовую публикацию Васи на стену Пети:

INSERT INTO wall_text VALUES (DEFAULT, 2, 1, 'Give me your money!', DEFAULT, DEFAULT);

SELECT * FROM wall_text;

-- 11. Создадим таблицу с фактом лайка публикации на стене одного пользователя другим.

CREATE TABLE liked(
	id SERIAL PRIMARY KEY,
	whom_user_id BIGINT UNSIGNED NOT NULL,
	from_user_id BIGINT UNSIGNED NOT NULL,
	is_liked BOOLEAN DEFAULT FALSE,
	liked_at DATETIME DEFAULT NOW(),
	FOREIGN KEY (whom_user_id) REFERENCES users (id),
	FOREIGN KEY (from_user_id) REFERENCES users (id),
	INDEX(whom_user_id),
	INDEX(from_user_id)
);

-- Добавим публикации Васи лайк от пользователя Пети:

INSERT INTO liked VALUES (DEFAULT, 2, 1, DEFAULT, DEFAULT);

SELECT * FROM liked;