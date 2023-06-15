/*
Ejer1 Se desea implementar el pago de comisiones a los vendedores para poder mostrar 
su salario y su comision siendo la comision un poporcentaje igual para todosl 
los trabajador, actualizar el salario base como 1025 y el porcetaje de comision como 15%
*/

alter table staff add column salary float;
alter table staff add column commission float;

update staff set salary = 1025;
update staff set commission = 15;

select * from staff;

/*
Ejer2 Mostrar todas la ventas de los trabajdores ordenas por tienda y por genero de pelicula desendentemente
*/

select * from payment p ;

select s.store_id, c.name, p.* from payment p 
    inner join rental r on p.rental_id = r.rental_id 
    inner join inventory i on r.inventory_id = i.inventory_id 
    inner join film_category fc on i.film_id = fc.film_id 
    inner join category c on fc.category_id = c.category_id 
    inner join staff st on p.staff_id = st.staff_id 
    inner join store s on st.store_id = s.store_id 
    group by s.store_id, c.name, p.payment_id 
    order by s.store_id ASC, c.name DESC;

	
/*
Ejer3 crear los siguientes reportes 
- Lista de precio de las peliculas de alquiler 
- Monto de venta por cada vendedor por cada año u mes dentro del sistema
*/

select f.title, f.rental_rate from film f;

select f.title, f.rental_rate from rental r 
    inner join inventory i on r.inventory_id = i.inventory_id 
    inner join film f on i.film_id = f.film_id 
    where r.return_date is null;

------------------------------------
 
SELECT routine_name
FROM information_schema.routines
WHERE routine_type='FUNCTION' AND specific_schema='public';



 
SELECT pg_get_functiondef(p.oid)
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' -- Cambiar por el esquema donde se encuentra la función
AND p.proname = 'rewards_report'; -- Cambiar por el nombre de la función






SELECT pg_get_functiondef(p.oid)
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
INNER JOIN (
	SELECT routine_name
	FROM information_schema.routines
	WHERE routine_type='FUNCTION' AND specific_schema='public'
) pr ON p.pronamespace = n.oid
WHERE n.nspname = 'public' -- Cambiar por el esquema donde se encuentra la función
AND p.proname = pr.routine_name; -- Cambiar por el nombre de la función


