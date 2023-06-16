/*
1. Declare, calcule e imprima el promedio de antigüedad de Las películas, si es mayor a 15 años
imprima 'Cine Clásico, de lo contario ‘Cine Moderno.
*/

create or replace function films_avg() returns void as
$$
declare
    current_year film.release_year%type;
    release_year_avg film.release_year%type;
begin
	current_year := extract(year from CURRENT_DATE);
	select avg(f.release_year) from film f into release_year_avg;
    if current_year - release_year_avg > 15 then
        raise notice 'release year avg: % => Cine Clásico', release_year_avg;
    else 
        raise notice 'release year avg: % => Cine Moderno', release_year_avg;
    end if;
    return;
end 
$$ 
language 'plpgsql';

select films_avg();

/*
2. Crear un programa sql que cambie el mail de un cliente, tabla customer, por otro que se pasará
como parámetro, recibirá dos parámetros, el identificador del cliente y el nuevo mail.
*/

create or replace function update_customer_email(in c_id customer.customer_id%type, in c_email customer.email%type) returns void as
$$
begin
	update customer set email = c_email
        where customer_id = c_id;
    
    if not found then
        raise notice 'no found customer with id = %', c_id;
		return;
    end if;
   
exception
    when others then
        raise notice 'ERROR: %', SQLERRM;
        return;
end 
$$ 
language 'plpgsql';

select update_customer_email(600,'newemail@email.com');

/*3. Crea un programa sql que pase dos parámetros de entrada, identificador de categoría e
identificador de actor y obtenga los datos de las películas sobre esa categoría en las que ha
trabajado ese actor. Prueba el ejemplo con el actor 182 y la categoría 2.*/

create or replace function get_all_actor_category(in c_id category.category_id%type, in a_id actor.actor_id%type) returns setof film as
$$
declare
    cur cursor (c_id category.category_id%type, a_id actor.actor_id%type) for 
        select f.* from film f
        join film_category fc on fc.film_id = f.film_id
        join category c on c.category_id = fc.category_id and c.category_id = c_id
        join film_actor fa on fa.film_id = f.film_id and fa.actor_id = a_id
    group by f.film_id;

    rec record;
begin
	open cur(c_id, a_id);
    
    loop
        fetch cur into rec;
        exit when not found;
        return next rec;
    end loop;

    close cur;
    
    return;
exception
    when others then
        raise notice 'ERROR: %', SQLERRM;
        return;
end 
$$ 
language 'plpgsql';

select get_all_actor_category(1,10);
select get_all_actor_category(2,182);