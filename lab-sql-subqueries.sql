-- Welcome to the SQL Subqueries lab!

-- In this lab, you will be working with the Sakila database on movie rentals. Specifically, you will be practicing how to perform subqueries, which are queries embedded within other queries. Subqueries allow you to retrieve data from one or more tables and use that data in a separate query to retrieve more specific information.

-- Challenge
-- Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT * FROM inventory;
SELECT * FROM film;

SELECT 
    COUNT(i.film_id) 
FROM
    inventory i
WHERE
    i.film_id = (SELECT 
            f.film_id
        FROM
            film f
		WHERE
			title="Hunchback Impossible");

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT 
    title
FROM
    film f
WHERE
    length > (SELECT 
            AVG(length)
        FROM
            film);
-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT 
    a.first_name, a.last_name
FROM
    actor a
WHERE
    a.actor_id IN (
		SELECT fa.actor_id
        FROM film_actor fa
		WHERE fa.film_id = (
			SELECT f.film_id
			FROM film f
			WHERE f.title="Alone Trip"
	)
);

-- Bonus:

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM category;

SELECT 
    title
FROM
    film f
WHERE
    f.film_id IN (
		SELECT fc.film_id
        FROM film_category fc
		WHERE fc.category_id = (
			SELECT c.category_id
			FROM category c
			WHERE c.name="Family"
	)
);
-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ON a.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Canada';

SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ON a.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = (SELECT country
						 FROM country
                         WHERE country = 'Canada');
                         
-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT ac.actor_id, ac.first_name, ac.last_name, COUNT(fa.actor_id) AS 'film_count'
FROM sakila.actor AS ac
JOIN sakila.film_actor AS fa
ON ac.actor_id = fa.actor_id
GROUP BY ac.actor_id, ac.first_name, ac.last_name
ORDER BY film_count DESC
LIMIT 1;

SELECT 
    title
FROM
    film f
WHERE
    f.film_id IN (
		SELECT fa.film_id
        FROM film_actor fa
		WHERE fa.actor_id = (
			SELECT a.actor_id
			FROM actor a
			WHERE actor_id=107
	)
);
-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS rental_count 
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY rental_count DESC
LIMIT 1;

SELECT 
    title
FROM
    film f
WHERE
    f.film_id IN (
		SELECT i.film_id
        FROM inventory i
		WHERE i.inventory_id IN (
			SELECT r.inventory_id
			FROM rental r
			WHERE r.customer_id= '148'
	)
);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT c.last_name, c.first_name, c.customer_id, SUM(p.amount) AS 'Total_paid_by_customer' 
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
GROUP BY c.last_name
ORDER BY c.last_name ASC;

SELECT c.customer_id, SUM(p.amount) AS Total_amount_spent
FROM customer c
JOIN payment p ON p.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING SUM(p.amount) > (
    SELECT AVG(total_amount_spent)
    FROM (
        SELECT customer_id, SUM(amount) AS total_amount_spent
        FROM payment
        GROUP BY customer_id
    ) AS subquery
)
ORDER BY c.customer_id;


