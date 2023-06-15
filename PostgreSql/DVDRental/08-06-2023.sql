--CREATE database dvdrental;

select * from rental  order by rental_date asc
select * from payment p order by payment_date asc 
select * from film f order by f.release_year desc


CREATE OR REPLACE FUNCTION customer_rentals_payments(in p_year int) RETURNS void AS
$$
DECLARE
    cur cursor (p_year int) FOR 
   	    SELECT c.first_name, c.last_name, count(r.rental_id) as rentals, 
            sum(p.amount) as payments, extract(year from r.rental_date) as anio
        FROM customer c
        join rental r on c.customer_id = r.customer_id  and 
        	extract(year from r.rental_date) = p_year
        join payment p on p.rental_id = r.rental_id
        group by c.first_name, c.last_name, extract(year from r.rental_date)
        order by  c.first_name;
    rec record;
begin
	open cur(p_year);
   	LOOP 
        fetch cur into rec;
        exit when not found;

        raise notice 'name: % %, rentals: %, total payments %, anio: %',
            rec.first_name, rec.last_name,rec.rentals,rec.payments,rec.anio;
    END LOOP;
    close cur;
    RETURN;
END $$ LANGUAGE 'plpgsql';

select * from customer_rentals_payments(2006);




CREATE OR REPLACE FUNCTION customer_rentals_payments(in p_year int) RETURNS SETOF customer AS
$$
DECLARE
    cur cursor (p_year int) FOR 
   	    SELECT c.first_name, c.last_name, count(r.rental_id) as rentals, 
            sum(p.amount) as payments, extract(year from r.rental_date) as anio
        FROM customer c
        join rental r on c.customer_id = r.customer_id  and 
        	extract(year from r.rental_date) = p_year
        join payment p on p.rental_id = r.rental_id
        group by c.first_name, c.last_name, extract(year from r.rental_date)
        order by  c.first_name;
    rec record;
begin
	open cur(p_year);
    FOR rec in cur
   	LOOP 
        raise notice 'name: % %, rentals: %, total payments %, anio: %',
            rec.first_name, rec.last_name,rec.rentals,rec.payments,rec.anio;
    END LOOP;
    close cur;
    RETURN;
END $$ LANGUAGE 'plpgsql';

select * from customer_rentals_payments(2005);
