-- Partie 3 – Requêtes SQL de base
-- 1. Lister tous les clients triés par date de création de compte (plus anciens → plus récents).
SELECT * FROM tp_sql_avance.customers
ORDER BY customer_date_creation;

-- 2. Lister tous les produits (nom + prix) triés par prix décroissant.
SELECT product_name, product_price FROM tp_sql_avance.products
ORDER BY product_price DESC;

-- 3. Lister les commandes passées entre deux dates (par exemple entre le 1er et le 15 mars 2024).
SELECT * FROM tp_sql_avance.orders
WHERE order_date BETWEEN '2024-03-01' AND '2024-03-15';

-- 4. Lister les produits dont le prix est strictement supérieur à 50 €.
SELECT * FROM tp_sql_avance.products
WHERE product_price > 50;

-- 5. Lister tous les produits d’une catégorie donnée (par exemple “Électronique”).
SELECT product_name FROM tp_sql_avance.products
WHERE category_id = 
	(SELECT id_category 
	FROM tp_sql_avance.categories
	WHERE category_name = 'Électronique');


-- Partie 4 – Jointures simples
-- 1. Lister tous les produits avec le nom de leur catégorie.
SELECT product_name, category_name
FROM tp_sql_avance.products
INNER JOIN tp_sql_avance.categories 
ON products.category_id = categories.id_category;

-- 2. Lister toutes les commandes avec le nom complet du client (prénom + nom).
SELECT id_order, customer_firstname, customer_lastname
FROM tp_sql_avance.orders
INNER JOIN tp_sql_avance.customers
ON orders.customer_id = customers.id_customer;

-- 3. Lister toutes les lignes de commande avec le nom du client,
-- le nom du produit, la quantité, le prix unitaire facturé.
SELECT customer_firstname, customer_lastname, product_name, order_item_quantity, order_item_price_unit
FROM tp_sql_avance.customers c
INNER JOIN tp_sql_avance.orders o ON c.id_customer = o.customer_id
INNER JOIN tp_sql_avance.order_items oi ON o.id_order = oi.order_id
INNER JOIN tp_sql_avance.products p ON oi.product_id = p.id_product;

-- 4. Lister toutes les commandes dont le statut est `PAID` ou `SHIPPED`.
SELECT * FROM tp_sql_avance.orders
WHERE order_status = 'PAID' OR order_status = 'SHIPPED';


-- Partie 5 – Jointures avancées
-- 1. Afficher le détail complet de chaque commande avec 
-- date de commande,nom du client, liste des produits, quantité, 
-- prix unitaire facturé, montant total de la ligne (quantité × prix unitaire).
SELECT order_date, customer_lastname, customer_firstname, product_name, order_item_quantity,order_item_price_unit, (order_item_quantity*order_item_price_unit) as totel_price
FROM tp_sql_avance.customers c
INNER JOIN tp_sql_avance.orders o ON c.id_customer = o.customer_id
INNER JOIN tp_sql_avance.order_items oi ON o.id_order = oi.order_id
INNER JOIN tp_sql_avance.products p ON oi.product_id = p.id_product;

-- 2. Calculer le **montant total de chaque commande** et afficher uniquement :
-- l’ID de la commande, le nom du client, le montant total de la commande.
SELECT id_order, customer_lastname, customer_firstname, ROUND(SUM(oi.order_item_quantity * oi.order_item_price_unit)::numeric,2) as total_order
FROM tp_sql_avance.customers c
INNER JOIN tp_sql_avance.orders o ON c.id_customer = o.customer_id
INNER JOIN tp_sql_avance.order_items oi ON o.id_order = oi.order_id
GROUP BY id_order, customer_lastname, customer_firstname
ORDER BY o.id_order;

--3. Afficher les commandes dont le montant total **dépasse 100 €**.
SELECT id_order, customer_lastname, customer_firstname, ROUND(SUM(oi.order_item_quantity * oi.order_item_price_unit)::numeric,2) as total_order
FROM tp_sql_avance.customers c
INNER JOIN tp_sql_avance.orders o ON c.id_customer = o.customer_id
INNER JOIN tp_sql_avance.order_items oi ON o.id_order = oi.order_id
GROUP BY id_order, customer_lastname, customer_firstname
HAVING SUM(oi.order_item_quantity * oi.order_item_price_unit) > 100
ORDER BY o.id_order;

-- 4. Lister les catégories avec leur **chiffre d’affaires total** 
-- (somme du montant des lignes sur tous les produits de cette catégorie).
SELECT category_name, ROUND(SUM(oi.order_item_quantity * oi.order_item_price_unit)::numeric,2) as total_category
FROM tp_sql_avance.categories c
INNER JOIN tp_sql_avance.products p ON c.id_category = p.category_id
INNER JOIN tp_sql_avance.order_items oi ON p.id_product = oi.product_id
INNER JOIN tp_sql_avance.orders o ON oi.order_id = o.id_order
WHERE o.order_status IN ('PAID', 'SHIPPED')
GROUP BY c.category_name;


-- Partie 6 – Sous-requêtes
-- 1. Lister les produits qui ont été vendus **au moins une fois**.
SELECT product_name, SUM(order_item_quantity) as total_product
FROM tp_sql_avance.products p
INNER JOIN tp_sql_avance.order_items oi ON p.id_product = oi.product_id
INNER JOIN tp_sql_avance.orders o ON oi.order_id = o.id_order
WHERE o.order_status IN ('PAID', 'SHIPPED')
GROUP BY p.product_name
HAVING SUM(oi.order_item_quantity) > 0;