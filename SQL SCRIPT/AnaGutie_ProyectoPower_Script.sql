/*
PROYECTO DE CONSULTAS SQL
SCRIP DE ANA GUTIÉRREZ HERNÁNDEZ

Una vez cargada la base de datos en DBeaver y generado el esquema ER
puedo ver que se trata de un negocio de alquiler de películas.

Observando el esquema se percibe que los datos y tablas se dividen
pricnipalmente en aquellos relacionados con las películas,
y en los relacionados con las ventas (clientes, tiendas, facturas...).
Estos dos ámbitos se relacionan gracias a la tabla inventory.

Una vez familiarizada con el esquema de la base de datos (1ª petición
del proyecto) procedo a realizar las consultas solicitadas

2. Muestra los nombres de todas las películas con una clasificación por 
edades de ‘Rʼ:

La clasificación de las películas es la columna rating de la tabla film
Selecciono las columnas title y rating filtro por esta última para
que aparezcan sólo los valores = R (películas restringidas y con supervisión para menores de 17)
*/

SELECT title, rating AS clasificacion 
FROM film 
WHERE "rating" = 'R'; 

/*
 3. Encuentra los nombres de los actores que tengan un “actor_idˮ
 entre 30 y 40:
 
 Para ello en la tabla actor selecciono las categorías de ID, y uno 
 en una concatenación nombre y apellidos para una mejor legibilidad.
 */
SELECT
    actor_id,
    CONCAT(first_name, ' ', last_name) AS Nombre_Completo_Actor
FROM actor
WHERE "actor_id" BETWEEN 30 AND 40; --Filtro los ID entre 30 y 40


/*
 4. Obtén las películas cuyo idioma coincide con el idioma original:
 
 En la tabla Film encuentro las columnas language_id y original_language_id
 Esta última conecta con la tabla language donde se ecuentra el nombre del idioma.
 Para comprobar cuáles son las coincidencias, uno ambas tablas con un INNER JOIN
 que decuelve sólo las filas que son iguales en ambas tablas, en este caso en la
 categoría de language_id (idioma de la película) en la tabla film, y en la tabla
 de languaje con languaje_id que realmente corresponde con el idioma original.
 A esto sumo name para poder visualizar el idioma del que se trata y el nombre de la película. 
*/

SELECT 
    f.language_id, l.language_id,
    l.name, f.title
FROM film AS f
INNER JOIN language AS l
ON f.original_language_id = l.Language_id; 

 /* No da error pero tampoco resultados, por eso copio y hago un letf join, 
 así compruebo si aparecen recurrentevente valores nulos es que simplemente
 no coincide niguna fila y todas las películas están traducidas.
 */
SELECT 
    f.language_id, l.language_id,
    l.name, f.title
FROM film AS f
LEFT JOIN language AS l
ON f.original_language_id = l.Language_id; 
-- los valores no coincidentes se rellenan como nulos, y así sucede con todos
-- la primera consulta es por tanto correcta.

/* 
 5. Ordena las películas por duración de forma ascendente: 
 
 La duración es la columna length de la tabla film, así que hago esa selección
 y añado el nombre y id para identificarlas, junto con el filtro ORDERBY
 con la columna length en orden ascendente.
 */
SELECT film_id, title, length AS Duracion_min 
FROM film
ORDER BY length ASC; 

 /* 
 6. Encuentra el nombre y apellido de los actores que tengan ‘Allenʼ en su 
apellido:

Selecciono el nombre y apellidos de los actores y aplico un filtro para la 
columna de apellido en el que sin importat mayúsuculas o minúsculas aparezcan
las filas que contengan Allen. 
 */
SELECT CONCAT (first_name, ' ', last_name) AS Nombre_Completo_Actor 
FROM actor 
WHERE "last_name" ILIKE '%Allen%'; 

/* 
 7.  Encuentra la cantidad total de películas en cada clasificación de la tabla 
“filmˮ y muestra la clasificación junto con el recuento:

Desde la tabla film selecciono la clasificación (columna rating).
Agrupo por clasificación o rating y hago un conteo (COUNT) de las filas desde la fila del select,
es decir, películas que corresponden a esas clasificaciones.
 */
SELECT rating AS clasificacion, COUNT (rating) AS Cantidad_de_peliculas 
FROM film
GROUP BY rating ; 

/* 
 8. Encuentra el título de todas las películas que son ‘PG-13ʼ o tienen una 
duración mayor a 3 horas en la tabla film: 
 */
SELECT title, rating AS clasificacion, length AS duracion  
FROM film 
--Primero selecciono las películas de clasificacion PG-13 
WHERE "rating" = 'PG-13' 
--Ahora añado un operador que a estas incluya películas de duración mayor a 3h (180min)
OR "length" > '180'
-- Las ordeno para que se muestren primero las películas más largas
-- Esto último unicamente para que los resultados tengan un orden y se lean mejor
ORDER BY length DESC;  

/* 
 9. Encuentra la variabilidad de lo que costaría reemplazar las películas:
 
La desviación estandar mide cuánto se alejan los valores de la media,
en el caso del coste de remplazar una película.
 **/
SELECT ROUND(STDDEV("replacement_cost"),2) AS variabilidad_coste_reemplazo
FROM film; -- redondeo dos decimales porque para representar un coste monetario son suficientes

/* 
 10. Encuentra la mayor y menor duración de una película de nuestra BBDD:
 */
SELECT 
    MIN("length") AS Minima_duracion, 
    MAX("length") AS Maxima_duracion
FROM film ;

/* 
 11.  Encuentra lo que costó el antepenúltimo alquiler ordenado por día:
 */
SELECT r.rental_date, p.amount AS coste_alquiler --Selecciono los datos que quiero
FROM rental AS r
    JOIN payment AS p --Uno las tablas en las que se encuentran
    ON r.rental_id = p.rental_id
ORDER BY r.rental_date DESC --Ordeno por fecha para que aparezcan los últimos alquileres primero
OFFSET 2 --Pido que empiece la consulta saltando los dos primeros resultados
LIMIT 1; --Limito a 1 resultado para obtener sólo el antepenúltimo

/* 
 12.Encuentra el título de las películas en la tabla “filmˮ que no sean
 ni NC-17 ni ‘Gʼ en cuanto a su clasificación:
 */
SELECT title, rating AS clasificacion
FROM film
WHERE "rating" NOT IN ('NC-17', 'G'); --filtro eliminando esas clasificaciones

/* 
 13. Encuentra el promedio de duración de las películas para cada 
clasificación de la tabla film y muestra la clasificación junto con el 
promedio de duración:
 */
SELECT rating AS Clasificacion, 
    ROUND(AVG (length),0) AS Duracion_media --promedio de la duración de las películas
    -- Redondeo sin decimales la media porque al tratare de minutos no necesitamos decimales
FROM film
GROUP BY "rating";

/* 
 14. Encuentra el título de todas las películas que tengan una duración mayor 
a 180 minutos:
 */
SELECT title, length AS duracion_minutos
FROM film
WHERE "length" > '180' -- filtro por duración mayor a 180min
ORDER BY "duracion_minutos" ASC; -- Ordeno los resultados para mejor legibilidad

/* 
 15. ¿Cuánto dinero ha generado en total la empresa?:
 */
SELECT ROUND(SUM (amount),2) AS Ingresos_totales 
--sumo todas las cantidades cobradas y redondeo en 2 decimales porque no es necesario más
FROM Payment;

/* 
 16. Muestra los 10 clientes con mayor valor de id:
 */
SELECT customer_id, 
    CONCAT(first_name, ' ',last_name) AS Nombre_Cliente
FROM customer
ORDER BY "customer_id" DESC -- Los ordeno para que aparezcan primero los ID más grandes
LIMIT 10; -- Y hago que sólo aparezcan 10 resultados

/* 
 17.  Encuentra el nombre y apellido de los actores que aparecen en la 
película con título ‘Egg Igbyʼ:

Para ello conecto la tabla flim donde está el título de la película y su ID
con la tabla actor donde están los nombres y ID de los actores, mediante la
table flim_actor que contiene ID tanto de actores como películas.
 */
SELECT 
    CONCAT (a.first_name, ' ', a.last_name) AS Nombre_actores,
    f.title -- Selecciono los datos que busco referenciados en sus tablas correspondientes
FROM film AS f -- Selecciono la tabla de películas
    INNER JOIN film_actor AS f_a --Uno la tabla intermedia
    ON f.film_id = f_a.film_id 
    INNER JOIN actor AS a --Uno la tabla de actores
    ON f_a.actor_id = a.actor_id 
WHERE "title" = 'EGG IGBY'; -- Filtro para que sólo aparezcan datos de la película EGG IGBY

--Otra opción es la siguiente, realizar una subconsulta entre tablas:

SELECT CONCAT (a.first_name, ' ', a.last_name) AS Nombre_actores
FROM actor AS a
WHERE actor_id IN (
        SELECT actor_id
        FROM film_actor
        WHERE film_id IN (
            SELECT film_id
            FROM film
            WHERE "title" = 'EGG IGBY'
     ));

/* 
 18. Selecciona todos los nombres de las películas únicos:
 */
SELECT DISTINCT ("title") AS Nombres_unicos --El comando selecciona los valores únicos de la columna
FROM film;

/* 
 19. Encuentra el título de las películas que son comedias y tienen una 
duración mayor a 180 minutos en la tabla “filmˮ:

Para ello uno la tabla film donde está título y duración, a la tabla category donde podré seleccionar las comedias,
todo mediante la tabla film_categry que contiene el ID tanto de las pelíclas como de las categorías
 */
SELECT f.film_id, f.title, f.length AS duracion_minutos, c.name 
FROM film AS f
    INNER JOIN film_category AS f_c -- Uno la tabla de los identificadores
    ON f.film_id = f_c.film_id 
    INNER JOIN category AS c-- Uno la tabla de las categorías
    ON f_c.category_id = c.category_id 
WHERE f."length" > '180' -- filtro por duración mayor a 180min
 AND c."name" = 'Comedy'
ORDER BY "duracion_minutos" ASC; -- Ordeno los resultados para mejor legibilidad

-- También podría realizar subconsultas para conseguir la información
SELECT film_id, title, length --Además del título, otros elementos para situar la información
FROM film 
WHERE "length" > '180'
AND film_id IN (
    SELECT film_id
    FROM film_category 
    WHERE category_id IN (
        SELECT category_id
        FROM category
        WHERE "name" = 'Comedy'
    )); 

/* 
 20.  Encuentra las categorías de películas que tienen un promedio de 
duración superior a 110 minutos y muestra el nombre de la categoría 
junto con el promedio de duración.
 */

SELECT   c.name, ROUND(AVG(f.length),0) AS duracion_media --redondeo para mostrar sólo los minutos
FROM film AS f
    INNER JOIN film_category AS f_c -- Uno la tabla de los identificadores
    ON f.film_id = f_c.film_id 
    INNER JOIN category AS c-- Uno la tabla de las categorías
    ON f_c.category_id = c.category_id
GROUP BY c."name"
HAVING ROUND(AVG(f."length"),0) > '110'; -- Añado un filtro para las películas de duración mayor a 110min

/* 
 21. ¿Cuál es la media de duración del alquiler de las películas?:
 
 Hago una resta de las fechas de devolución y alquiler, y sobre ello, la media
 */
SELECT AVG("return_date" - "rental_date") AS Media_tiempo_devolucion
FROM rental;
--Esta es la media concreta con todos los datos, para mejor legibilidad calculo sólo los días:

SELECT ROUND(AVG(EXTRACT(DAY FROM "return_date" - "rental_date")), 2) AS Media_tiempo_devolucion
FROM rental; 
--También redondeo porque muchos decimales son innecesarios

/* 
 22.Crea una columna con el nombre y apellidos de todos los actores y 
actrices:
 */
SELECT actor_id, CONCAT (first_name, ' ', last_name) AS Nombre_y_Apellidos_actores
FROM actor; -- selecciono también el ID para mejor lectura de los resultados

/* 
 23. Números de alquiler por día, ordenados por cantidad de alquiler de 
forma descendente:
En primer lugar extraigo la fecha de la columna rental_date para poder seleccionar
los datos de los días completos, porque la columna contiene datos de incluso
minutos, y de no hacerlo resultarían la mayoría valores únicos.
 */
SELECT 
    DATE(rental_date) AS fecha,
    COUNT(rental_id) AS Num_de_alquileres
FROM rental
GROUP BY "fecha"
ORDER BY "fecha" DESC;

/* 
 24. Encuentra las películas con una duración superior al promedio:
 */

SELECT title, length
FROM film
WHERE length > ( --Hago una subconsulta para cualcular la duración media y poder compararla
        SELECT AVG(length)
        FROM film
        );

/* 
 25. Averigua el número de alquileres registrados por mes:
 */
SELECT 
    DATE_TRUNC('month', rental_date) AS mes, --Selecciono de la columna fehca sólo el mes
    COUNT(rental_id) AS conteo_de_alquileres --Realizo una cuenta de los alquileres registrados
FROM rental
GROUP BY mes --Secciono ese conteo por el mes extraido de la columna de fecha
ORDER BY mes DESC; --Los ordeno por fecha para mejor lectura de resultados


/* 
 26.  Encuentra el promedio, la desviación estándar y varianza del total 
pagado:
 */
SELECT ROUND(AVG("amount"),2) AS Promedio_total_pagado --Promedio de cantidadad pagada
FROM payment; --Redondeo a dos decimales porque más de dos son innecesarios

SELECT ROUND(STDDEV("amount"),2) AS DesvEst_total_pagado --Desviación estándar de la cantidadad pagada total
FROM payment; --Redondeo a dos decimales porque más de dos son innecesarios

SELECT ROUND(VARIANCE("amount"),2) AS Varianza_total_pagado--Varianza de la cantidadad pagada total
FROM payment; --Redondeo a dos decimales porque más de dos son innecesarios


/* 
 27.  ¿Qué películas se alquilan por encima del precio medio?:
 */

SELECT film_id, title, rental_rate --Seleciono datos que quiero ver de las películas
FROM film
WHERE rental_rate > ( --Mediante una subconsulta calculo el precio medio para filtrar por el mismo 
    SELECT AVG("rental_rate")
    FROM film
 ); 


/* 
 28. Muestra el id de los actores que hayan participado en más de 40 
películas:
 */
SELECT actor_id --seleciono la informacion pedida
FROM film_actor
GROUP BY actor_id -- agrupo por cada actor para poder hacer una operación aritmentica
HAVING COUNT(film_id) > 40; --filtro por el conteo de películas 
 
/* 
 29. Obtener todas las películas y, si están disponibles en el inventario, 
mostrar la cantidad disponible:
Para mostrar todas haya o no disponibilidad y que esta se señale, hago un LEFT JOIN
que muestre toda la unión de los datos de las películas y su disponiblidad 
quedando valores nulos para las no disponibles y la muestra de la cantidad en caso positivo
 */
SELECT f.film_id, f.title, 
       COUNT(i.inventory_id) AS cantidad_disponible
FROM film AS f
    LEFT JOIN inventory AS i 
    ON f.film_id = i.film_id
GROUP BY f.film_id, f.title
ORDER BY cantidad_disponible DESC;

/* 
 30. Obtener los actores y el número de películas en las que ha actuado:
 */
SELECT 
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS Nombre_completo, 
    COUNT(fa.film_id) AS num_peliculas --Suma de las películas
FROM actor AS a 
    LEFT JOIN film_actor AS fa 
    ON a.actor_id = fa.actor_id --Uno las dos talas que contienen la información
GROUP BY a.actor_id, a.first_name, a.last_name --Agrupo los datos para poder hacer el conteo
ORDER BY num_peliculas DESC; --Ordenado para una lectura más cómoda

/* 
 31. Obtener todas las películas y mostrar los actores que han actuado en 
ellas, incluso si algunas películas no tienen actores asociados:
 */
SELECT 
    f.film_id, f.title, --Selecciono la información que quiero de la tabla f
    a.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS Nombre_completo  --Y lo mismo con la tabla a
FROM film f
    LEFT JOIN film_actor AS fa
     ON f.film_id = fa.film_id --Uno las tablas
    LEFT JOIN actor AS a
     ON fa.actor_id = a.actor_id --Si no hubiera resultados aparecerán valores nulos
ORDER BY f.film_id, a.actor_id; --Ordeno los resultados para mejor legibilidad

/* 
 32.Obtener todos los actores y mostrar las películas en las que han 
actuado, incluso si algunos actores no han actuado en ninguna película:
 
 En este caso realizamos el JOIN partiendo de la tabla de actores
 para así contar con todos los actores y si algún dato no tiene correspondencia
 en la unión saldrá como NULL pero se seguirán pudiendo observar todos los actores.
 */

SELECT 
    f.film_id, f.title,
    a.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS Nombre_completo 
FROM actor a
    LEFT JOIN film_actor AS fa
     ON a.actor_id = fa.actor_id
    LEFT JOIN film AS f
     ON fa.film_id = f.film_id
ORDER BY a.actor_id, f.film_id;

-- Podría hacerse también cambiando la formula de la consulta anterior (31) a un RIGHT JOIN 
SELECT 
    f.film_id, f.title, --Selecciono la información que quiero de la tabla f
    a.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS Nombre_completo  --Y lo mismo con la tabla a
FROM film f
    RIGHT JOIN film_actor AS fa
     ON f.film_id = fa.film_id --Uno las tablas
    RIGHT JOIN actor AS a
     ON fa.actor_id = a.actor_id --Si no hubiera resultados aparecerán valores nulos
ORDER BY a.actor_id, f.film_id;


/*  
 33. Obtener todas las películas que tenemos y todos los registros de 
alquiler:
 */
SELECT f.film_id, f.title, --Selecciono las películas con su título
    r.rental_id, r.rental_date --Y el registro de alquiler correspondiente
FROM film AS f
    INNER JOIN inventory AS i --Uno las tablas para poder juntar la información
        ON f.film_id = i.film_id
    INNER JOIN rental AS r
        ON i.inventory_id = r.inventory_id
ORDER BY rental_date ASC; --Lo ordeno para mejor legibilidad de resultados

/* 
 34.  Encuentra los 5 clientes que más dinero se hayan gastado con nosotros:
 */
SELECT r.customer_id, --Selecciono los datos pedidos
    CONCAT (c.first_name, ' ', c.last_name) AS Nombre_cliente, --Incluyo nombres para mejor identificación
    SUM(p.amount) AS Total_gastado
FROM rental AS r --Uno todas las tablas donde están los diferentes datos
    INNER JOIN  payment AS p
    ON r.rental_id = p.rental_id 
    INNER JOIN customer AS c
    ON r.customer_id = c.customer_id
GROUP BY r.customer_id, CONCAT (c.first_name, ' ', c.last_name) --Agrupo por clientes para tener la suma en función de estos
ORDER BY SUM(p.amount) DESC -- Ordeno de forma que aparezcan primero quienes más han gastado
LIMIT 5; -- Limito los resultados a 5 clientes


/* 
 35. Selecciona todos los actores cuyo primer nombre es 'Johnny':
 */
SELECT actor_id, CONCAT (first_name, ' ', last_name) AS Nombre_completo
FROM actor
WHERE first_name ILIKE '%Johnny%'; -- Filtro resultados por nombre sin importar mayúsculas o minúsculas

/* 
 36. Renombra la columna “first_nameˮ como Nombre y “last_nameˮ como 
Apellido: 
 */
SELECT first_name AS Nombre,
    last_name AS Apellido
FROM actor;

/* 
 37.Encuentra el ID del actor más bajo y más alto en la tabla actor:
 */
SELECT MIN(actor_id) AS Actor_mas_abajo,
    MAX(actor_id) AS Actor_mas_alto,
FROM actor; 

/* 
 38.Cuenta cuántos actores hay en la tabla “actorˮ:
 */
SELECT COUNT(actor_id) AS Num_de_actores --COUNT cuenta los id de la columna
FROM actor;

/* 
 39.  Selecciona todos los actores y ordénalos por apellido en orden 
ascendente:
 */
SELECT first_name AS Nombre,
    last_name AS Apellido
FROM actor
ORDER BY Apellido ASC; --Ordeno los resultados en orden ascendente según apellido

/* 
 40. Selecciona las primeras 5 películas de la tabla “filmˮ:
 */

SELECT film_id, title
FROM film
LIMIT 5; --Limito los resultados a 5 para mostrar los 5 primeros únicamente

/* 
 41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el 
mismo nombre. ¿Cuál es el nombre más repetido?:
 */
SELECT first_name, COUNT (first_name) AS num_nombre_repetidos --Selecciono los datos pedidos
FROM actor
GROUP BY first_name --Agrupo por nombre 
ORDER BY num_nombre_repetidos DESC; --Ordeno para que salgan primero los nombres más repetidos


/* 
 42.  Encuentra todos los alquileres y los nombres de los clientes que los 
realizaron:
 */

SELECT r.rental_id AS identificador_alquiler,
    CONCAT (c.first_name, ' ', c.last_name) AS Nombre_cliente
FROM rental AS r
    INNER JOIN customer AS c --Uno sólo los datos de la tabla costumen que coincidan con algún alquiler
    ON r.customer_id = c.customer_id;

/* 
 43. Muestra todos los clientes y sus alquileres si existen, incluyendo 
aquellos que no tienen alquileres:

En este caso al unir las tablas no sólo lo hago para mostrar sólo los resultados coincidentes
sino que uso un RIGTH JOIN para mostrar también los clientes sin alquileres
(aparecerá NULL en la celda del alquiler)
 */
SELECT c.customer_id, CONCAT (c.first_name, ' ', c.last_name) AS Nombre_cliente,
    r. rental_id
FROM Rental AS r
    RIGHT JOIN customer AS c --Se parte de esta tabla para mostrar todos los clientes
    ON r.customer_id = c.customer_id
ORDER BY customer_id DESC; 
    

/* 
 44.  Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor 
esta consulta? ¿Por qué? Deja después de la consulta la contestación:
 */
SELECT * 
FROM Film AS f
    CROSS JOIN category AS c;
/*
 No aporta valor porque nos muestra todas las combinaciones posbiles que resultan 
de la combinación de las tablas y esto no tiene sentido porque las películas y categorías
ya tienen una relación concreta entre sí que esta unión no tiene en cuenta.
 */

/* 
 45.  Encuentra los actores que han participado en películas de la categoría 
'Action':
 */
SELECT actor_id, CONCAT(first_name, ' ', last_name) AS Nombre_completo
FROM actor
WHERE actor_id IN (
    SELECT f_a.actor_id
    FROM film_actor AS f_a
    WHERE f_a.film_id IN (
        SELECT f_c.film_id
        FROM film_category AS f_c
            INNER JOIN category c 
            ON f_c.category_id = c.category_id
        WHERE c.name = 'Action'
    ) );

/* 
 46.  Encuentra todos los actores que no han participado en películas:
 */
SELECT a.actor_id, CONCAT (a.first_name, ' ', a.last_name) AS Nombre_completo
FROM actor AS a
WHERE NOT EXISTS ( --Indico que NO exista registro de el id del actor en ninguna película
    SELECT a.actor_id, f_a.film_id
    FROM actor AS a
    INNER JOIN film_actor AS f_a
    ON a.actor_id = f_a.actor_id
); --NO da error pero tampoco resultados, todos los actores han participado en películas

/* 
 47. Selecciona el nombre de los actores y la cantidad de películas en las 
que han participado:
 */
SELECT a.actor_id, CONCAT (a.first_name, ' ', a.last_name) AS Nombre_completo,
    COUNT(f_a.film_id) AS num_peliculas --Sumo la cantidad de películas 
FROM actor AS a
 INNER JOIN film_actor AS f_a 
     ON a.actor_id = f_a.actor_id
GROUP BY a.actor_id; --Agrupo por identificador de actor para mosrtar la suma de películas en función de estos

/* 
 48. Crea una vista llamada “actor_num_peliculasˮ que muestre los nombres 
de los actores y el número de películas en las que han participado:
 */
-- Uso la consulta del ejercicio anterior

CREATE VIEW actor_num_peliculas AS
SELECT a.actor_id, CONCAT (a.first_name, ' ', a.last_name) AS Nombre_completo,
    COUNT(f_a.film_id) AS num_peliculas 
FROM actor AS a
 INNER JOIN film_actor AS f_a 
     ON a.actor_id = f_a.actor_id
GROUP BY a.actor_id;

--Para visualizar esta vista creada ejecutaría:
SELECT *
FROM actor_num_peliculas; 

/* 
 49. Calcula el número total de alquileres realizados por cada cliente:
 */
SELECT c.customer_id, CONCAT (c.first_name, ' ', c.last_name) AS Nombre_cliente,
    COUNT (r.rental_id) AS Total_alquileres --Recuento de los alquileres
FROM Customer AS c
    INNER JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id --Agrupo por clientes para que la suma sea en función de estos
ORDER BY Total_alquileres; --Ordeno para facilitar la lectura de resultados


/* 
 50. Calcula la duración total de las películas en la categoría 'Action':
 */

SELECT SUM(f.length) AS duracion_total --Sumo las duraciones de las películas
FROM film AS f
    INNER JOIN film_category AS fc 
    ON f.film_id = fc.film_id
    INNER JOIN category AS c 
    ON fc.category_id = c.category_id
WHERE c.name = 'Action'; --Selecciono únicamente las categorizadas como Action

/* 
 51. Crea una tabla temporal llamada “cliente_rentas_temporalˮ para 
almacenar el total de alquileres por cliente:
 */
WITH cliente_rentas_temporal AS ( --Así nombro y creo la CTE
    SELECT c.customer_id, CONCAT (c.first_name, ' ', c.last_name) AS nombre_cliente,
        COUNT(r.rental_id) AS Num_alquileres --Cuento los alquileres realizados
    FROM customer AS c
        INNER JOIN rental AS r
        ON c.customer_id = r.customer_id
    GROUP BY c.customer_id --Agrupo por cliente para realizar el conteo en función de estos
)
--A continuación selecciono la CTE para comprobar su funcionamiento
SELECT *
FROM cliente_rentas_temporal;

/* 
 52. Crea una tabla temporal llamada “peliculas_alquiladasˮ que almacene las 
películas que han sido alquiladas al menos 10 veces:
 */
WITH peliculas_alquiladas AS ( --creo la tabla temporal
    SELECT f.film_id, f.title,
        COUNT(r.rental_id) AS total_alquileres --Selecciono los datos relevantes
    FROM film AS f 
        INNER JOIN inventory AS i
        ON f.film_id = i.film_id
        INNER JOIN rental AS r
        ON r.inventory_id = i.inventory_id
   GROUP BY f.film_id, f.title --Agrupo por películas para contear los alquileres en función de estas
    HAVING COUNT(r.rental_id) >= 10 --Filtro el conteo para películas alquiladas 10 o más veces
)
--A continuación selecciono la CTE para comprobar su funcionamiento
SELECT *
FROM peliculas_alquiladas
;

/* 
 53. Encuentra el título de las películas que han sido alquiladas por el cliente 
con el nombre ‘Tammy Sandersʼ y que aún no se han devuelto. Ordena 
los resultados alfabéticamente por título de película:
 */
SELECT f.film_id, f.title --Los datos finales que quiero son el título de la película
FROM film AS f --Uno las tablas con todos los datos que necesito
    INNER JOIN inventory AS i
    ON f.film_id = i.film_id
    INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
    INNER JOIN customer AS c
    ON r.customer_id = c.customer_id
WHERE r.return_date IS NULL --Filtro por peliculas que NO constan como devueltas
AND CONCAT (c.first_name, ' ',c.last_name) = 'TAMMY SANDERS' --Filtro por nombre y apellidos
ORDER BY f.title; --Ordeno alfabeticamente según título

/* 
 54.  Encuentra los nombres de los actores que han actuado en al menos una 
película que pertenece a la categoría ‘Sci-Fiʼ. Ordena los resultados 
alfabéticamente por apellido:
 */
SELECT actor_id, CONCAT(first_name, ' ', last_name) AS Nombre_actor
FROM actor
WHERE actor_id IN ( --Relaciono las tablas de actores y categorías mediante subconsultas
    SELECT f_a.actor_id
    FROM film_actor AS f_a
    WHERE f_a.film_id IN ( --Uso IN en lugar de hacer JOINS constantes de tablas para evitar duplicados
        SELECT f_c.film_id
        FROM film_category AS f_c
            INNER JOIN category AS c
            ON f_c.category_id = c.category_id
        WHERE c.name = 'Sci-Fi' --Selecciono la categoría Sci-Fi
    ) )
ORDER BY last_name ASC; --Ordeno alfabeticamente


/* 
 55. Encuentra el nombre y apellido de los actores que han actuado en 
películas que se alquilaron después de que la película ‘Spartacus 
Cheaperʼ se alquilara por primera vez. Ordena los resultados 
alfabéticamente por apellido:
 */
SELECT DISTINCT --uso DISTINCIT porque se pueden repetir los actores que aparecen en películas
    a.actor_id, a.last_name AS apellido, a.first_name AS nombre
FROM actor AS a
--Uno todas las tablas para llegar a la información sobre las fechas de alquiler en rental
    INNER JOIN film_actor AS f_a
    ON a.actor_id = f_a.actor_id
    INNER JOIN film AS f
    ON f_a.film_id = f.film_id
    INNER JOIN inventory AS i
    ON f.film_id = i.film_id
    INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
-- A continuación filtro por películas alquiladas con fecha posterior a la subconsulta
WHERE r.rental_date > (
    SELECT MIN(r.rental_date) --Consulto la primera fecha de alquiler de la película
    FROM rental AS r
        INNER JOIN inventory AS i
        ON r.inventory_id = i.inventory_id
        INNER JOIN film AS f
        ON i.film_id = f.film_id
    WHERE f.title = 'SPARTACUS CHEAPER' --Selecciono únicamente la película mencionada
)
ORDER BY a.last_name, a.first_name --Ordeno alfabeticamente; 


/* 
 56. Encuentra el nombre y apellido de los actores que NO han actuado en 
ninguna película de la categoría ‘Musicʼ:
 */
SELECT a.first_name, a.last_name --Selecciono los datos pedidos
FROM actor a
WHERE a.actor_id NOT IN ( --Filtro para que los resultados NO coindican con la subconsulta de la categoría MUSIC
    SELECT f_a.actor_id
    FROM film_actor AS f_a
        INNER JOIN film_category AS f_c 
        ON f_a.film_id = f_c.film_id
        INNER JOIN category AS c 
        ON f_c.category_id = c.category_id
    WHERE c.name = 'Music'
)
ORDER BY a.last_name ASC; --Ordeno alfabeticamente

/* 
 57. Encuentra el título de todas las películas que fueron alquiladas por más 
de 8 días:
 */
SELECT DISTINCT f.film_id, f.title --Selecciono los datos que quiero obtener
--Uso Distinct porque se puede repetir una misma película alquilada más de 8 días
FROM film AS f
    INNER JOIN inventory AS i --Uno las tablas donde está la diferente información
    ON  i.film_id = f.film_id
    INNER JOIN rental AS r
    ON r.inventory_id = i.inventory_id
WHERE (r.return_date - r.rental_date) > INTERVAL '8 days'
--Filtro por intervalo de tiempo al tener los datos un formato fecha
ORDER BY title; --Ordeno para mayor comodidad al leer los resultados



/* 
 58. Encuentra el título de todas las películas que son de la misma categoría 
que ‘Animationʼ:
 */
SELECT f.film_id, f.title, c.name AS categoria --Selecciono los datos que quiero obtener
FROM film AS f 
    INNER JOIN film_category AS f_c --Uno las tablas donde está la diferente información
    ON f.film_id = f_c.film_id
    INNER JOIN Category AS c
    ON f_c.category_id = c.category_id
WHERE c.name = ( --Filtro en esta subconsulta para seleccionar por categoría Animation
    SELECT c.name
    FROM category AS c
    WHERE c.name = 'Animation' 
)
ORDER BY title; --Ordeno para mayor comodidad al leer los resultados


/* 
 59. Encuentra los nombres de las películas que tienen la misma duración 
que la película con el título ‘Dancing Feverʼ. Ordena los resultados 
alfabéticamente por título de película:
 */
SELECT film_id, title, length --Selecciono datos pedidos
FROM film
WHERE length = ( --Filtro por igualdad de duración
    SELECT length
    FROM film
    WHERE title = 'DANCING FEVER') --Selecciono la película a cuya duración debe igualarse
ORDER BY title; --Ordeno alfabeticamente por título


/* 
 60.  Encuentra los nombres de los clientes que han alquilado al menos 7 
películas distintas. Ordena los resultados alfabéticamente por apellido:
 */
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS Nombre_cliente,
       COUNT(DISTINCT i.film_id) AS Num_alquileres 
FROM customer AS c
    JOIN rental AS r
    ON c.customer_id = r.customer_id
    JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
GROUP BY c.customer_id, c.first_name, c.last_name --Agrupo para contar según clientes
HAVING COUNT(DISTINCT i.film_id) >= 7 --Filtro por más de 7 películas distintas
ORDER BY Num_alquileres; --Ordeno para mejor lectura de resultados


/* 
 61. Encuentra la cantidad total de películas alquiladas por categoría y 
muestra el nombre de la categoría junto con el recuento de alquileres:
 */
SELECT c.name AS categoria, 
       (SELECT COUNT(rental_id) --Selecciono mediante subconsulta el total de alquileres
        FROM rental AS r
        WHERE r.inventory_id IN ( 
            SELECT i.inventory_id 
            FROM inventory i
            WHERE i.film_id IN ( 
                SELECT f_c.film_id 
                FROM film_category AS f_c 
                WHERE f_c.category_id = c.category_id
            ) ) --Con estas subconsultas hago que el conteo sea según categorías
       ) AS total_alquileres 
FROM category c
ORDER BY total_alquileres DESC;

/* 
 62.  Encuentra el número de películas por categoría estrenadas en 2006:
 */
SELECT c.name AS categoria, COUNT (f.film_id) AS Num_estrenos --Selecciono datos pedidos
FROM film AS f
    INNER JOIN film_category AS f_c
    ON f.film_id = f_c.film_id
    INNER JOIN category AS c 
    ON f_c.category_id = c.category_id
WHERE f.release_year = '2006' --Filtro los resultados por estrenos en 2006
GROUP BY c.name ; --Agrupo para que se recuenten las eplículas en función de la categoría

/* 
 63. Obtén todas las combinaciones posibles de trabajadores con las tiendas 
que tenemos:
 */
SELECT sto.store_id,
    CONCAT('ID:',sf.staff_id, ' ', first_name, ' ', last_name) AS Datos_empleado
FROM Store AS sto
CROSS JOIN Staff AS sf;
-- He decidido cocatenar el ID y el nombre para facilitar la lectura de la consulta
-- Así aparecen únicamnete dos columnas, referentes a tienda y empleados respectivamente.

/* 
 64.  Encuentra la cantidad total de películas alquiladas por cada cliente y 
muestra el ID del cliente, su nombre y apellido junto con la cantidad de 
películas alquiladas:
 */
SELECT c.customer_id, CONCAT (c.first_name, ' ', c.last_name) AS Nombre_cliente, --Selecciono datos pedidos
    COUNT(r.rental_id) AS total_pelis_alquiladas --Cuento los identificadores de alquiler
FROM customer AS c
    INNER JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id --Agrupo por clientes para que la suma sea en función de ello
ORDER BY total_pelis_alquiladas DESC; --Ordeno para que sea más facil leer los resultados en un orden

