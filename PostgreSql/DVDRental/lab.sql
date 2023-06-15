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

   
select staff.first_name || ' ' || staff.last_name as full_name,
	date_trunc('year', payment.payment_date) as sales_year,
  	date_trunc('month', payment.payment_date) as sales_month,
	SUM(payment.amount) as total
	from public.payment 
	inner join public.staff on payment.staff_id = staff.staff_id
	group by 1, 2, 3
	order by 1;

 
select staff.first_name || ' ' || staff.last_name as full_name,
	to_char(extract(year from payment.payment_date), '9999') as sales_year,
  	to_char(extract(month from payment.payment_date), '99') as sales_month,
	SUM(payment.amount) as total
	from public.payment 
	inner join public.staff on payment.staff_id = staff.staff_id
	group by 1, 2, 3
	order by 1;

 
 

