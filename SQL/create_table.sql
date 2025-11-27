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

