CREATE SCHEMA dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
 
 
-- -----------------------// Queries \\----------------------  
-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) AS total_amount
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, count(DISTINCT order_date) AS days_visited 
FROM sales 
GROUP BY customer_id;
  
-- 3. What was the first item from the menu purchased by each customer?

WITH CTE AS (
SELECT customer_id, product_id, row_number() OVER(PARTITION BY customer_id ORDER BY order_date) AS rn
FROM sales
)
SELECT c.customer_id, m.product_name AS first_purchased_dish
FROM CTE c
JOIN menu m ON c.product_id = m.product_id
WHERE rn = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name AS most_purchased_dish, COUNT(s.product_id) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name 
ORDER BY purchase_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH CTE AS (
SELECT customer_id, product_id, COUNT(product_id) AS cnt
FROM sales
GROUP BY customer_id, product_id
),
rnk AS (
SELECT c.customer_id, c.product_id, m.product_name, DENSE_RANK() OVER(PARTITION BY c.customer_id ORDER BY cnt DESC) AS rn
FROM CTE c
JOIN menu m ON c.product_id = m.product_id
		)
SELECT customer_id, product_name AS most_popular_product
FROM rnk
WHERE rn = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH member_join_date AS (
SELECT s.customer_id, s.order_date, m1.product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS rnk
FROM sales s
JOIN menu m1 ON s.product_id = m1.product_id
JOIN members m2 ON s.customer_id = m2.customer_id
WHERE s.order_date >= m2.join_date 
)
SELECT customer_id AS member_name, product_name AS first_dish
FROM member_join_date
WHERE rnk = 1;

-- 7. Which item was purchased just before the customer became a member?

WITH member_join_date AS (
SELECT s.customer_id, s.order_date, m1.product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS rnk
FROM sales s
JOIN menu m1 ON s.product_id = m1.product_id
JOIN members m2 ON s.customer_id = m2.customer_id
WHERE s.order_date <= m2.join_date 
)
SELECT customer_id AS member_name, product_name AS last_dish_before_member
FROM member_join_date
WHERE rnk = 1;

-- 8. What is the total items and amount spent for each member before they became a member? 

WITH member_join_date AS (
SELECT s.customer_id, s.order_date, m1.product_name, m1.price
FROM sales s
JOIN menu m1 ON s.product_id = m1.product_id
JOIN members m2 ON s.customer_id = m2.customer_id
WHERE s.order_date < m2.join_date 
GROUP BY s.customer_id, s.order_date, m1.product_name, m1.price
)
SELECT customer_id, COUNT(product_name) AS total_items, SUM(price) AS total_spent
FROM member_join_date
GROUP BY customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH spend_sum AS (
	SELECT s.customer_id, m.product_name, SUM(m.price) total_spent
	FROM sales s
	JOIN menu m ON s.product_id = m.product_id
	GROUP BY s.customer_id, m.product_name
				)
SELECT ss.customer_id, (
	SELECT SUM(CASE WHEN product_name = "sushi" THEN total_spent * 20 ELSE total_spent * 10 END) 
    FROM spend_sum ss2
    WHERE ss2.customer_id = ss.customer_id
    ) AS points
FROM spend_sum ss
GROUP BY ss.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
-- 	   how many points do customer A and B have at the end of January?

WITH jan AS (
		SELECT MIN(order_date) AS start_day, MAX(order_date) AS end_day
		FROM sales  
        WHERE MONTH(order_date) = 1),
	 earning_points AS (
		SELECT s.customer_id, s.order_date, m2.join_date, 
				CASE 
					WHEN s.order_date >= start_day AND s.order_date < m2.join_date AND m.product_name = "sushi" THEN m.price * 20		-- BEFORE JOIN DATE
					WHEN s.order_date >= start_day AND s.order_date < m2.join_date THEN m.price * 10
                    WHEN s.order_date >= m2.join_date AND s.order_date <= DATE_ADD(m2.join_date, INTERVAL 6 DAY) THEN m.price * 20		-- JOINING POINTS 
                    WHEN s.order_date > DATE_ADD(m2.join_date, INTERVAL 6 DAY) AND s.order_date <= end_day AND m.product_name = "sushi" THEN m.price * 20
                    WHEN s.order_date > DATE_ADD(m2.join_date, INTERVAL 6 DAY) AND s.order_date <= end_day THEN m.price * 10 END AS points
		FROM sales s
        JOIN menu m  ON s.product_id = m.product_id
        JOIN members m2 ON s.customer_id = m2.customer_id
        JOIN jan
)
SELECT customer_id, SUM(points) AS total_points
FROM earning_points
GROUP BY customer_id;


														-- // PROJECT COMPLETED \\ --
															-- // THANK YOU \\ --