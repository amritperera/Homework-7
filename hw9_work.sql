-- Amrit Perera
USE sakila;

-- Test Actor
SELECT * FROM actor;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT * FROM actor WHERE first_name="Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor WHERE last_name LIKE '%li%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN("Afghanistan","Bangladesh","China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor 
-- named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `description` BLOB NULL AFTER `last_update`;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `description`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT last_name, COUNT(*) num FROM actor GROUP BY last_name HAVING num > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE `sakila`.`actor` SET `first_name` = 'HARPO' WHERE (`actor_id` = '172');

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE `sakila`.`actor` SET `first_name` = 'GROUCHO' WHERE (`first_name` = 'HARPO');

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address 
FROM staff INNER JOIN address 
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, Total
FROM staff INNER JOIN (SELECT payment.staff_id, SUM(payment.amount) AS Total
	FROM payment
	WHERE payment_date BETWEEN '2005-08-01' AND '2005-08-31'
	GROUP BY staff_id) as sub
ON staff.staff_id = sub.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT title, number_of_actors
FROM film INNER JOIN (SELECT COUNT(actor_id) AS number_of_actors , film_id
	FROM film_actor
	GROUP BY film_id) AS sub
ON film.film_id = sub.film_id;

--  6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title, inventory.film_id, COUNT(*) AS copies
FROM inventory INNER JOIN film
ON inventory.film_id = film.film_id
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.customer_id, first_name, last_name, SUM(amount) AS total_paid
FROM customer INNER JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have 
-- also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM (SELECT title, language_id
	FROM  film
	WHERE title LIKE "K%" OR title LIKE "Q%") AS sub
WHERE sub.language_id = 1;

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT actor.actor_id, first_name, last_name
FROM actor INNER JOIN (SELECT actor_id
	FROM film_actor INNER JOIN (SELECT film_id 
		FROM film
		WHERE title = "Alone Trip") AS sub
	ON film_actor.film_id = sub.film_id) AS subb
ON actor.actor_id=subb.actor_id;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- (CANADA ID = 20)
-- get all Canadian cities
SELECT city_id, city
FROM city 
WHERE country_id = 20;

-- get all addresses in Canada (previous query nested)
SELECT address, address_id
FROM address INNER JOIN (SELECT city_id, city
	FROM city 
	WHERE country_id = 20) as sub
ON address.city_id = sub.city_id;

-- get all customers that have addresses in Canada (two previous queries nested)
SELECT first_name, last_name, email
FROM customer INNER JOIN (SELECT address, address_id
	FROM address INNER JOIN (SELECT city_id, city
		FROM city 
		WHERE country_id = 20) as sub
	ON address.city_id = sub.city_id) AS subb
ON customer.address_id = subb.address_id;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT film.film_id, title
FROM film INNER JOIN (SELECT film_id, film_category.category_id
	FROM film_category INNER JOIN (SELECT category_id, name
		FROM category
		WHERE name = "Family") AS sub
	ON film_category.category_id = sub.category_id) AS subb
ON film.film_id = subb.film_id;

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(title) as Num
FROM film INNER JOIN (SELECT rental_id, rental.inventory_id, film_id 
	FROM rental INNER JOIN inventory
	ON rental.inventory_id = inventory.inventory_id) as sub
ON film.film_id = sub.film_id
GROUP BY title
ORDER BY Num DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- staff_id is the same as store_id
SELECT staff_id AS store_id, SUM(amount) AS total
FROM payment
GROUP BY staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM country INNER JOIN (SELECT store_id, city, country_id
	FROM city INNER JOIN (SELECT store_id, city_id
		FROM store INNER JOIN address
		ON store.address_id = address.address_id) AS sub
	ON city.city_id =  sub.city_id) AS subb
ON country.country_id = subb.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT rental_id, rental.inventory_id, film_id 
FROM rental INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id;

SELECT payment.rental_id, film_id, amount
FROM payment INNER JOIN (SELECT rental_id, rental.inventory_id, film_id 
	FROM rental INNER JOIN inventory
	ON rental.inventory_id = inventory.inventory_id) AS sub
ON payment.rental_id = sub.rental_id;

SELECT rental_id, film_category.film_id, amount, category_id
FROM film_category INNER JOIN (SELECT payment.rental_id, film_id, amount
	FROM payment INNER JOIN (SELECT rental_id, rental.inventory_id, film_id 
		FROM rental INNER JOIN inventory
		ON rental.inventory_id = inventory.inventory_id) AS sub
	ON payment.rental_id = sub.rental_id) as subb
ON film_category.film_id = subb.film_id;

SELECT rental_id, film_id, amount, category.category_id, name
FROM category INNER JOIN (SELECT rental_id, film_category.film_id, amount, category_id
	FROM film_category INNER JOIN (SELECT payment.rental_id, film_id, amount
		FROM payment INNER JOIN (SELECT rental_id, rental.inventory_id, film_id 
			FROM rental INNER JOIN inventory
			ON rental.inventory_id = inventory.inventory_id) AS sub
		ON payment.rental_id = sub.rental_id) as subb
	ON film_category.film_id = subb.film_id) AS subbb
ON category.category_id = subbb.category_id;
-- ------------FINAL QUERY 7H------------------------------------------------------------
SELECT name, SUM(amount) AS Total
FROM category INNER JOIN (SELECT rental_id, film_category.film_id, amount, category_id
	FROM film_category INNER JOIN (SELECT payment.rental_id, film_id, amount
		FROM payment INNER JOIN (SELECT rental_id, rental.inventory_id, film_id 
			FROM rental INNER JOIN inventory
			ON rental.inventory_id = inventory.inventory_id) AS sub
		ON payment.rental_id = sub.rental_id) as subb
	ON film_category.film_id = subb.film_id) AS subbb
ON category.category_id = subbb.category_id
GROUP BY name
ORDER BY Total DESC;
-- ----------------- 7H Using Joins----------------------------------------------------------------------
SELECT SUM(amount) AS gross_revenue,name
FROM rental INNER JOIN payment 
ON rental.rental_id = payment.rental_id
INNER JOIN inventory
ON inventory.inventory_id = rental.inventory_id
INNER JOIN film_category
ON inventory.film_id = film_category.film_id
INNER JOIN category
ON film_category.category_id = category.category_id
GROUP BY name
ORDER BY gross_revenue DESC;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_genres AS SELECT name, SUM(amount) AS Total
FROM category INNER JOIN (SELECT rental_id, film_category.film_id, amount, category_id
	FROM film_category INNER JOIN (SELECT payment.rental_id, film_id, amount
		FROM payment INNER JOIN (SELECT rental_id, rental.inventory_id, film_id 
			FROM rental INNER JOIN inventory
			ON rental.inventory_id = inventory.inventory_id) AS sub
		ON payment.rental_id = sub.rental_id) as subb
	ON film_category.film_id = subb.film_id) AS subbb
ON category.category_id = subbb.category_id
GROUP BY name
ORDER BY Total DESC;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_genres;
