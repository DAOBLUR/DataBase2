/*
1. Cree una función/procedimiento que permita visualizar la cantidad de alquileres y 
la suma de sus pagos de un determinado empleado ingresado por parámetro.
*/

CREATE OR REPLACE PROCEDURE show_staff_data(IN id integer)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    staff_name varchar(100);
    staff_rentals int;
    staff_payments float;
BEGIN
    SELECT concat(s.first_name,' ',s.last_name), 
            COUNT(r), SUM(f.rental_rate)
        FROM staff s into staff_name , staff_rentals, staff_payments
        INNER JOIN rental r ON r.staff_id = s.staff_id
        INNER JOIN inventory i ON i.inventory_id = r.inventory_id
        INNER JOIN film f ON f.film_id = i.film_id
        WHERE s.staff_id = id
        GROUP BY s.staff_id;

    RAISE NOTICE 'Staff Name: %, Total Rentals: %, Total Payments: %', 
   		staff_name, staff_rentals, staff_payments;
END;
$procedure$;

call show_staff_data(1);
call show_staff_data(2);

/*
2. Elabore una función/procedimiento que devuelva los títulos de películas, 
ordenadas por los actores.
*/

CREATE OR REPLACE PROCEDURE films_sort_by_actors()
LANGUAGE plpgsql
AS $procedure$
DECLARE
    rec record;
BEGIN
    FOR rec in (
        select f.title from film f 
		inner join film_actor fa on fa.film_id = f.film_id
		inner join actor a on a.actor_id = fa.actor_id
		GROUP by f.film_id, a.actor_id
		order by a.actor_id
    )
    LOOP
        RAISE NOTICE 'Film title: %', rec.title;
    END LOOP;
END;
$procedure$;

call films_sort_by_actors();

/*
3. Elabore una función/procedimiento que determine el número de películas por nombre 
de categoría
*/

CREATE OR REPLACE PROCEDURE films_number_category()
LANGUAGE plpgsql
AS $procedure$
DECLARE
    rec record;
BEGIN
    FOR rec IN (
        select c.name, count(f) as films_number from film f 
		inner join film_category fc on fc.film_id = f.film_id
		inner join category c on c.category_id = fc.category_id
		GROUP by c.category_id ,c.name
    )
    LOOP
        RAISE notice 'Category: % - %', rec.name, rec.films_number;
    END LOOP;
END;
$procedure$;

call films_number_category();

/*
4. Construya una función/procedimiento que devuelva los datos más significativos de 
las películas según su director
*/

create table director (
	director_id serial4 not null primary key,
	first_name varchar(45) not null,
	last_name varchar(45) not null,
	last_update timestamp not null
);

create table film_director (
	film_id int2 not null references film,
	director_id int2 not null references director,
	primary key (film_id, director_id)  
);


insert into director VALUES (1, 'Martin', 'Scorsese', '2016-06-22 19:10:25-07');
insert into director VALUES (2, 'Steven', 'Spielberg', '2016-06-22 19:10:25-07');
insert into director VALUES (3, 'Stanley', 'Kubrick', '2016-06-22 19:10:25-07');
insert into director VALUES (4, 'Quentin', 'Tarantino', '2016-06-22 19:10:25-07');
insert into director VALUES (5, 'Christopher', 'Nolan', '2016-06-22 19:10:25-07');

----------------
insert into film_director VALUES (1,1);
insert into film_director VALUES (2,1);
insert into film_director VALUES (3,1);
insert into film_director VALUES (4,1);
insert into film_director VALUES (5,1);
insert into film_director VALUES (6,1);
insert into film_director VALUES (7,1);
insert into film_director VALUES (8,1);
insert into film_director VALUES (9,1);
----
insert into film_director VALUES (1,2);
insert into film_director VALUES (12,2);
insert into film_director VALUES (13,2);
insert into film_director VALUES (14,2);
insert into film_director VALUES (15,2);
insert into film_director VALUES (16,2);
insert into film_director VALUES (17,2);
insert into film_director VALUES (18,2);
insert into film_director VALUES (19,2);
----
insert into film_director VALUES (12,3);
insert into film_director VALUES (22,3);
insert into film_director VALUES (23,3);
insert into film_director VALUES (24,3);
insert into film_director VALUES (25,3);
insert into film_director VALUES (26,3);
insert into film_director VALUES (27,3);
insert into film_director VALUES (28,3);
insert into film_director VALUES (29,3);
----
insert into film_director VALUES (22,4);
insert into film_director VALUES (32,4);
insert into film_director VALUES (33,4);
insert into film_director VALUES (34,4);
insert into film_director VALUES (35,4);
insert into film_director VALUES (36,4);
insert into film_director VALUES (37,4);
insert into film_director VALUES (38,4);
insert into film_director VALUES (39,4);
----
insert into film_director VALUES (32,5);
insert into film_director VALUES (42,5);
insert into film_director VALUES (43,5);
insert into film_director VALUES (44,5);
insert into film_director VALUES (45,5);
insert into film_director VALUES (46,5);
insert into film_director VALUES (47,5);
insert into film_director VALUES (48,5);
insert into film_director VALUES (49,5);
insert into film_director VALUES (56,5);
insert into film_director VALUES (57,5);
insert into film_director VALUES (58,5);
insert into film_director VALUES (59,5);

----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE show_directors_info()
language plpgsql
as $procedure$
declare
    rec record;
begin
    for rec in (
        select concat(d.first_name, ' ', d.last_name) as name, f.title, f.rental_rate, f.length
		from director d
		inner join film_director fd on fd.director_id = d.director_id
		inner join film f on f.film_id = fd.film_id
		group by d.director_id, f.title, f.rental_rate, f.length 
		order by d.director_id
    )
    loop
        raise notice 'Director: % - Film: % , % $ , % min', 
			rec.name, rec.title, rec.rental_rate, rec.length;
    end loop;
end;
$procedure$;

call show_directors_info();

/*
5. Inserte registros en la tabla categoría usando un procedimiento
*/
CREATE OR REPLACE PROCEDURE Insert_Category(in category_id category.category_id%type, 
    in category_name category.name%type, in category_update category.last_update%type)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    insert into category VALUES (category_id, category_name, category_update);
   commit;
END;
$procedure$;

call Insert_Category(17,'Anime','2016-06-22 19:10:25-07');
call Insert_Category(18,'Comic','2016-06-22 19:10:25-07');

select * from category;




--------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION category_film_actor() RETURNS VOID AS $$
DECLARE
    reg RECORD;
    cur CURSOR FOR SELECT c.category_id, c.name FROM category c;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO reg;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '- CATEGORY:  %', reg.name;
        
        DECLARE 
            reg2 RECORD;
            cur2 CURSOR FOR 
                SELECT f.film_id, f.title 
                FROM film f
                JOIN film_category fc ON fc.film_id = f.film_id
                WHERE fc.category_id = reg.category_id;
        
        BEGIN
            OPEN cur2;
            LOOP
                FETCH cur2 INTO reg2;
                EXIT WHEN NOT FOUND;
                RAISE NOTICE '  * FILM:  %', reg2.title;
                
                DECLARE 
                    reg3 RECORD;
                    cur3 CURSOR FOR 
                        SELECT a.first_name, a.last_name 
                        FROM actor a
                        JOIN film_actor fa ON fa.film_id = reg2.film_id
                        WHERE fa.actor_id = a.actor_id;
                    
                BEGIN
                    OPEN cur3;
                    LOOP
                        FETCH cur3 INTO reg3;
                        EXIT WHEN NOT FOUND;
                        RAISE NOTICE '    + ACTOR:  % %', reg3.first_name, reg3.last_name;
                    END LOOP;
                    CLOSE cur3;
                END;
            END LOOP;
            CLOSE cur2;
        END;
    END LOOP;
    CLOSE cur;
    RETURN;
END;
$$
LANGUAGE plpgsql;

select category_film_actor();
