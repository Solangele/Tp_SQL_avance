CREATE TABLE IF NOT EXISTS tp_sql_avance.categories(
	id_category INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	category_name VARCHAR(100) NOT NULL UNIQUE,
	category_description VARCHAR(255) 
);

CREATE TABLE IF NOT EXISTS tp_sql_avance.products(
	id_product INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	product_name VARCHAR(100) NOT NULL,
	product_price float CHECK(product_price > 0),
	product_stock INT CHECK(product_stock > 0),
	category_id INT NOT NULL,
	CONSTRAINT fk_category_id FOREIGN KEY (category_id)
		REFERENCES tp_sql_avance.categories(id_category)
);

CREATE TABLE IF NOT EXISTS tp_sql_avance.customers(
	id_customer INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_firstname VARCHAR(150) NOT NULL,
	customer_lastname VARCHAR(150) NOT NULL,
	customer_email VARCHAR(255) NOT NULL UNIQUE,
	customer_date_creation TIMESTAMP NOT NULL
);

CREATE TYPE status_enum AS ENUM ('PENDING', 'PAID', 'SHIPPED','CANCELLED');

CREATE TABLE IF NOT EXISTS tp_sql_avance.orders(
	id_order INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	order_date TIMESTAMP NOT NULL,
	order_status status_enum NOT NULL,
	customer_id INT NOT NULL,
	CONSTRAINT fk_customer_id FOREIGN KEY (customer_id)
		REFERENCES tp_sql_avance.customers(id_customer)
);


CREATE TABLE IF NOT EXISTS tp_sql_avance.order_items(
	id_order_item INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	order_item_quantity INT CHECK(order_item_quantity >= 0),
	order_item_price_unit FLOAT CHECK(order_item_price_unit > 0),
	product_id INT NOT NULL,
	order_id INT NOT NULL,
	CONSTRAINT fk_product_id FOREIGN KEY (product_id)
		REFERENCES tp_sql_avance.products(id_product),
	CONSTRAINT fk_order_id FOREIGN KEY (order_id)
		REFERENCES tp_sql_avance.orders(id_order)
);

INSERT INTO tp_sql_avance.categories (category_name, category_description) VALUES
  ('Électronique',       'Produits high-tech et accessoires'),
  ('Maison & Cuisine',   'Électroménager et ustensiles'),
  ('Sport & Loisirs',    'Articles de sport et plein air'),
  ('Beauté & Santé',     'Produits de beauté, hygiène, bien-être'),
  ('Jeux & Jouets',      'Jouets pour enfants et adultes');


INSERT INTO tp_sql_avance.products(product_name, product_price, product_stock, category_id) VALUES
  ('Casque Bluetooth X1000',        79.99,  50,  1),
  ('Souris Gamer Pro RGB',          49.90, 120,  1),
  ('Bouilloire Inox 1.7L',          29.99,  80,  2),
  ('Aspirateur Cyclonix 3000',     129.00,  40,  2),
  ('Tapis de Yoga Comfort+',        19.99, 150,  3),
  ('Haltères 5kg (paire)',          24.99,  70, 3),
  ('Crème hydratante BioSkin',      15.90, 200,  4),
  ('Gel douche FreshEnergy',         4.99, 300,  4),
  ('Puzzle 1000 pièces "Montagne"', 12.99,  95,  5),
  ('Jeu de société "Galaxy Quest"', 29.90,  60,  5);


INSERT INTO tp_sql_avance.customers(customer_firstname, customer_lastname, customer_email, customer_date_creation) VALUES
  ('Alice',  'Martin',    'alice.martin@mail.com',    '2024-01-10 14:32'),
  ('Bob',    'Dupont',    'bob.dupont@mail.com',      '2024-02-05 09:10'),
  ('Chloé',  'Bernard',   'chloe.bernard@mail.com',   '2024-03-12 17:22'),
  ('David',  'Robert',    'david.robert@mail.com',    '2024-01-29 11:45'),
  ('Emma',   'Leroy',     'emma.leroy@mail.com',      '2024-03-02 08:55'),
  ('Félix',  'Petit',     'felix.petit@mail.com',     '2024-02-18 16:40'),
  ('Hugo',   'Roussel',   'hugo.roussel@mail.com',    '2024-03-20 19:05'),
  ('Inès',   'Moreau',    'ines.moreau@mail.com',     '2024-01-17 10:15'),
  ('Julien', 'Fontaine',  'julien.fontaine@mail.com', '2024-01-23 13:55'),
  ('Katia',  'Garnier',   'katia.garnier@mail.com',   '2024-03-15 12:00');


INSERT INTO tp_sql_avance.orders(customer_id, order_date, order_status) VALUES
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='alice.martin@mail.com'),    '2024-03-01 10:20', 'PAID'),
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='bob.dupont@mail.com'),      '2024-03-04 09:12', 'SHIPPED'),
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='chloe.bernard@mail.com'),   '2024-03-08 15:02', 'PAID'),
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='david.robert@mail.com'),    '2024-03-09 11:45', 'CANCELLED'),
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='emma.leroy@mail.com'),      '2024-03-10 08:10', 'PAID'),
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='felix.petit@mail.com'),     '2024-03-11 13:50', 'PENDING'),
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='hugo.roussel@mail.com'),    '2024-03-15 19:30', 'SHIPPED'),
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='ines.moreau@mail.com'),     '2024-03-16 10:00', 'PAID'),
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='julien.fontaine@mail.com'), '2024-03-18 14:22', 'PAID'),
  ((SELECT id_customer FROM tp_sql_avance.customers WHERE customer_email='katia.garnier@mail.com'),   '2024-03-20 18:00', 'PENDING');

INSERT INTO order_items(order_id, product_id, order_item_quantity, order_item_price_unit) VALUES
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='alice.martin@mail.com' AND order_date ='2024-03-01 10:20'), 'Casque Bluetooth X1000',         1,  79.99),
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='alice.martin@mail.com' AND order_date ='2024-03-01 10:20'), 'Puzzle 1000 pièces "Montagne"', 2,  12.99),
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='bob.dupont@mail.com' AND order_date ='2024-03-04 09:12'), 'Tapis de Yoga Comfort+',        1,  19.99),
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='chloe.bernard@mail.com' AND order_date ='2024-03-08 15:02'), 'Bouilloire Inox 1.7L',          1,  29.99),
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='chloe.bernard@mail.com' AND order_date ='2024-03-08 15:02'), 'Gel douche FreshEnergy',        3,   4.99),
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='david.robert@mail.com' AND order_date ='2024-03-09 11:45'), 'Haltères 5kg (paire)',          1,  24.99),
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='emma.leroy@mail.com' AND order_date ='2024-03-10 08:10'), 'Crème hydratante BioSkin',      2,  15.90),
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='julien.fontaine@mail.com' AND order_date ='2024-03-18 14:22'), 'Jeu de société "Galaxy Quest"', 1,  29.90),
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='katia.garnier@mail.com' AND order_date ='2024-03-20 18:00'), 'Souris Gamer Pro RGB',          1,  49.90),
  ((SELECT id_order FROM tp_sql_avance.orders WHERE id_customer='katia.garnier@mail.com' AND order_date ='2024-03-20 18:00'), 'Gel douche FreshEnergy',        2,   4.99);

INSERT INTO tp_sql_avance.order_items(order_id, product_id, order_item_quantity, order_item_price_unit)
SELECT 
    o.id_order,
    p.id_product,
    data.qty,
    data.price
FROM (
    VALUES
      ('alice.martin@mail.com',  '2024-03-01 10:20', 'Casque Bluetooth X1000',         1,  79.99),
      ('alice.martin@mail.com',  '2024-03-01 10:20', 'Puzzle 1000 pièces "Montagne"', 2,  12.99),
      ('bob.dupont@mail.com',    '2024-03-04 09:12', 'Tapis de Yoga Comfort+',        1,  19.99),
      ('chloe.bernard@mail.com', '2024-03-08 15:02', 'Bouilloire Inox 1.7L',          1,  29.99),
      ('chloe.bernard@mail.com', '2024-03-08 15:02', 'Gel douche FreshEnergy',        3,   4.99),
      ('david.robert@mail.com',  '2024-03-09 11:45', 'Haltères 5kg (paire)',          1,  24.99),
      ('emma.leroy@mail.com',    '2024-03-10 08:10', 'Crème hydratante BioSkin',      2,  15.90),
      ('julien.fontaine@mail.com','2024-03-18 14:22','Jeu de société "Galaxy Quest"', 1,  29.90),
      ('katia.garnier@mail.com', '2024-03-20 18:00', 'Souris Gamer Pro RGB',          1,  49.90),
      ('katia.garnier@mail.com', '2024-03-20 18:00', 'Gel douche FreshEnergy',        2,   4.99)
) AS data(email, date, product_name, qty, price)
JOIN tp_sql_avance.customers c ON c.customer_email = data.email
JOIN tp_sql_avance.orders o ON o.customer_id = c.id_customer AND o.order_date = data.date::timestamp
JOIN tp_sql_avance.products p ON p.product_name = data.product_name;


SELECT * FROM tp_sql_avance.order_items;