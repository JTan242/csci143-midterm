/* PROBLEM 1:
 *
 * The Office of Foreign Assets Control (OFAC) is the portion of the US government that enforces international sanctions.
 * OFAC is conducting an investigation of the Pagila company to see if you are complying with sanctions against North Korea.
 * Current sanctions limit the amount of money that can be transferred into or out of North Korea to $5000 per year.
 * (You don't have to read the official sanctions documents, but they're available online at <https://home.treasury.gov/policy-issues/financial-sanctions/sanctions-programs-and-country-information/north-korea-sanctions>.)
 * You have been assigned to assist the OFAC auditors.
 *
 * Write a SQL query that:
 * Computes the total revenue from customers in North Korea.
 *
 * NOTE:
 * All payments in the pagila database occurred in 2022,
 * so there is no need to do a breakdown of revenue per year.
 */

SELECT SUM(payment.amount)
FROM payment
JOIN customer USING(customer_id)
JOIN address USING(address_id)
JOIN city USING(city_id)
JOIN country USING(country_id)
WHERE country.country = 'North Korea';



/* PROBLEM 2:
 *
 * Management wants to hire a family-friendly actor to do a commercial,
 * and so they want to know which family-friendly actors generate the most revenue.
 *
 * Write a SQL query that:
 * Lists the first and last names of all actors who have appeared in movies in the "Family" category,
 * but that have never appeared in movies in the "Horror" category.
 * For each actor, you should also list the total amount that customers have paid to rent films that the actor has been in.
 * Order the results so that actors generating the most revenue are at the top.
 */

WITH ActorInFamily AS(
   SELECT DISTINCT actor.actor_id
    From actor
    JOIN film_actor ON actor.actor_id = film_actor.actor_id
    JOIN film ON film_actor.film_id = film.film_id
    JOIN film_category ON film.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id
    WHERE category.name = 'Family'),
ActorInHorror AS(
    SELECT DISTINCT actor.actor_id
    FROM actor
    JOIN film_actor ON actor.actor_id = film_actor.actor_id
    JOIN film ON film_actor.film_id = film.film_id
    JOIN film_category ON film.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id
    WHERE category.name = 'Horror'),
ActorMatch AS(
    SELECT actor.actor_id, actor.first_name, actor.last_name
    FROM actor
    WHERE actor.actor_id IN (SELECT actor_id FROM ActorInFamily)
    AND actor.actor_id NOT IN (SELECT actor_id FROM ActorInHorror))
SELECT m.first_name,m.last_name, COALESCE(SUM(p.amount), 0) AS revenue
FROM ActorMatch m
LEFT JOIN film_actor fa ON m.actor_id = fa.actor_id
LEFT JOIN film f ON fa.film_id = f.film_id
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY m.actor_id, m.first_name, m.last_name
ORDER BY revenue DESC;






/* PROBLEM 3:
 *
 * You love the acting in AGENT TRUMAN, but you hate the actor RUSSELL BACALL.
 *
 * Write a SQL query that lists all of the actors who starred in AGENT TRUMAN
 * but have never co-starred with RUSSEL BACALL in any movie.
 */

SELECT a1.first_name,a1.last_name
FROM actor a1 
JOIN film_actor fa1 ON a1.actor_id=fa1.actor_id
JOIN film f1 ON f1.film_id=fa1.film_id
WHERE f1.title = 'AGENT TRUMAN'
AND a1.actor_id NOT IN (
    SELECT a2.actor_id
    FROM actor a2
    JOIN film_actor fa2 ON a2.actor_id=fa2.actor_id
    JOIN film f2 ON f2.film_id=fa2.film_id
    WHERE f2.film_id IN (
        SELECT f3.film_id
        FROM film f3
        JOIN film_actor fa3 ON f3.film_id=fa3.film_id
        JOIN actor a3 ON fa3.actor_id = a3.actor_id
        WHERE a3.first_name= 'RUSSELL' AND a3.last_name = 'BACALL'
    )
);




/* PROBLEM 4:
 *
 * You want to watch a movie tonight.
 * But you're superstitious,
 * and don't want anything to do with the letter 'F'.
 * List the titles of all movies that:
 * 1) do not have the letter 'F' in their title,
 * 2) have no actors with the letter 'F' in their names (first or last),
 * 3) have never been rented by a customer with the letter 'F' in their names (first or last).
 *
 * NOTE:
 * Your results should not contain any duplicate titles.
 */

SELECT title
FROM film
LEFT JOIN (
    SELECT film_id
    FROM film_actor
    JOIN actor USING (actor_id)
    WHERE first_name LIKE '%F%' OR last_name LIKE '%F%'
) AS t2 USING (film_id)
LEFT JOIN (
    SELECT DISTINCT inventory.film_id
    FROM rental
    JOIN inventory USING (inventory_id)
    JOIN customer USING (customer_id)
    WHERE first_name LIKE '%F%' OR last_name LIKE '%F%'
) AS t3 USING (film_id)
WHERE title NOT LIKE '%F%' AND t2.film_id IS NULL AND t3.film_id IS NULL;





