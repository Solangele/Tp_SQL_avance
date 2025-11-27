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


-- 2. Lister les produits qui **n’ont jamais été vendus**.
SELECT product_name
FROM tp_sql_avance.products 
WHERE id_product NOT IN 
(SELECT product_id FROM tp_sql_avance.order_items);


-- 3. Trouver le client qui a **dépensé le plus** 
-- (TOP 1 en chiffre d’affaires cumulé).
SELECT customer_firstname, customer_lastname, (order_item_quantity*order_item_price_unit)
FROM tp_sql_avance.customers
INNER JOIN tp_sql_avance.orders ON id_customer = customer_id
INNER JOIN tp_sql_avance.order_items ON id_order = order_id
WHERE orders.order_status IN ('PAID', 'SHIPPED')
ORDER BY (order_item_quantity*order_item_price_unit) DESC
LIMIT 1;

-- 4. Afficher les **3 produits les plus vendus** en termes de quantité totale.
SELECT product_name, SUM(order_item_quantity)
FROM tp_sql_avance.products 
INNER JOIN tp_sql_avance.order_items ON id_product = product_id
GROUP BY product_name
ORDER BY SUM(order_item_quantity) DESC LIMIT 3;


-- 5. Lister les commandes dont le montant total est 
-- **strictement supérieur à la moyenne** de toutes les commandes.
SELECT (order_item_quantity*order_item_price_unit) as sup_order_average
FROM tp_sql_avance.order_items
WHERE (order_item_quantity*order_item_price_unit) > 
	(SELECT AVG(order_item_quantity*order_item_price_unit)
	 FROM tp_sql_avance.order_items);

-- Partie 7 – Statistiques & agrégats
-- 1. Calculer le **chiffre d’affaires total** 
-- (toutes commandes confondues, hors commandes annulées si souhaité).
SELECT SUM(order_item_quantity*order_item_price_unit) as total_orders
FROM tp_sql_avance.order_items
INNER JOIN tp_sql_avance.orders ON order_id = id_order
WHERE  orders.order_status IN ('PAID', 'SHIPPED', 'PENDING');


-- 2. Calculer le **panier moyen** (montant moyen par commande).
SELECT ROUND(AVG(order_item_quantity*order_item_price_unit)::numeric,2) AS average_orders
FROM tp_sql_avance.order_items;


-- 3. Calculer la **quantité totale vendue par catégorie**.
SELECT category_name, ROUND(SUM(order_item_quantity*order_item_price_unit)::numeric,2) AS sum_order_by_category
FROM tp_sql_avance.categories
INNER JOIN tp_sql_avance.products ON id_category = category_id
INNER JOIN tp_sql_avance.order_items ON id_product = product_id
INNER JOIN tp_sql_avance.orders ON order_id = id_order
WHERE  orders.order_status IN ('PAID', 'SHIPPED')
GROUP BY category_name;


-- 4. Calculer le **chiffre d’affaires par mois** 
-- (au moins sur les données fournies).
SELECT ROUND(SUM(order_item_quantity*order_item_price_unit)::numeric,2)
FROM tp_sql_avance.order_items
INNER JOIN tp_sql_avance.orders ON order_id = id_order
WHERE orders.order_date BETWEEN '2024-03-01' AND '2024-03-31'
AND orders.order_status IN ('PAID', 'SHIPPED');


-- 8 – Logique conditionnelle (CASE)
-- 1. Pour chaque commande, afficher :
-- l’ID de la commande, le client, la date, le statut, une version “lisible” du statut en français via `CASE` :
-- `PAID` → “Payée”, `SHIPPED` → “Expédiée”, `PENDING` → “En attente” ,`CANCELLED` → “Annulée”
SELECT id_order, customer_lastname, customer_firstname, order_date, 
	CASE 
		WHEN order_status = 'PAID' THEN 'Payée'
		WHEN order_status = 'SHIPPED' THEN 'Expédiée'
		WHEN order_status = 'PENDING' THEN 'En attente'
		WHEN order_status = 'CANCELLED' THEN 'Annulée'
	END as order_status
FROM tp_sql_avance.customers
INNER JOIN tp_sql_avance.orders ON id_customer = customer_id;


-- 2. Pour chaque client, calculer le **montant total dépensé** 
-- et le classer en segments :
-- `< 100 €`  → “Bronze”, `100–300 €` → “Argent”, `> 300 €`  → “Or”
-- Afficher : prénom, nom, montant total, segment.
SELECT customer_firstname, customer_lastname, ROUND(SUM(order_item_quantity*order_item_price_unit)::numeric,2),
	CASE 
		WHEN SUM(order_item_quantity*order_item_price_unit) < 100 THEN 'Bronze'
		WHEN SUM(order_item_quantity*order_item_price_unit) BETWEEN 100 AND 300 THEN 'Silver'
		WHEN SUM(order_item_quantity*order_item_price_unit) > 300 THEN 'Gold'
	END
FROM tp_sql_avance.customers
INNER JOIN tp_sql_avance.orders ON id_customer = customer_id
INNER JOIN tp_sql_avance.order_items ON id_order = order_id
GROUP BY customer_firstname, customer_lastname;