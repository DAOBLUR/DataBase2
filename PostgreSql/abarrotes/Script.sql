CREATE DATABASE abarrotes;

--------------------------------------------------------------------------------------------------------------------------------
--                  TABLES
--------------------------------------------------------------------------------------------------------------------------------

create table cliente (
    id_cliente int not null primary key,
    nombre varchar(40) not null,
    direccion varchar(40) not null,
    telefono varchar(15) not null,
    ciudad varchar(40) not null
);

create table producto (
    id_producto int not null primary key,
    descripcion text not null,
    precio float not null
);

create table venta (
    id_venta int not null primary key,
    cantidad int not null,
    id_cliente int not null references cliente,
    id_producto int not null references producto
);

--------------------------------------------------------------------------------------------------------------------------------
--                  DATA
--------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------
--                  CLIENTE
---------------------------------------------------

INSERT inTO CLIENTE VALUES(123,'Simon Bolivar', 'Kra11#9-56', '7702291', 'Cali');
INSERT inTO CLIENTE VALUES(456,'Mark Zuckerberg', 'Cll 21#95-52', '+57-315291', 'Medellin');
INSERT inTO CLIENTE VALUES(789,'Drew Barrymore', 'Kra52#65-05', '3125359456', 'Cali');
INSERT inTO CLIENTE VALUES(741,'Larry Page', 'Cll 05#52-95', '7872296', 'Tunja');
INSERT inTO CLIENTE VALUES(147,'Tom Delonge', 'Cll 52#65-56', '7992293', 'Medellin');
INSERT inTO CLIENTE VALUES(852,'Simon Bolivar', 'Kra 21#65-52', '982295', 'Bogota');
INSERT inTO CLIENTE VALUES(258,'Mark Hoppus', 'Cll 11#95-9', '8952294', 'Bogota');
INSERT inTO CLIENTE VALUES(963,'Britney Spears', 'Cll 05#52-56', '7705295', 'Tunja');
INSERT inTO CLIENTE VALUES(369,'John Forbes Nash', 'Kra 21#05-56', '776622966', 'Cali');
INSERT inTO CLIENTE VALUES(159,'Tom Delonge', 'Kra05#65-05', '6702293','Medellin');
INSERT inTO CLIENTE VALUES(753,'Sergey Brin', 'Cll 11#65-11', '9702299', 'Medellin');
INSERT inTO CLIENTE VALUES(153,'Emma Watson', 'Kra 9#9-95', '31569638', 'Tunja');

---------------------------------------------------
--                  PRODUCTO
---------------------------------------------------

INSERT inTO PRODUCTO VALUES(1,'Coca-Cola 2L',2400);
INSERT inTO PRODUCTO VALUES(2,'Doritos',1000);
INSERT inTO PRODUCTO VALUES(3,'Salchicha',3600);
INSERT inTO PRODUCTO VALUES(4,'Pan',500);
INSERT inTO PRODUCTO VALUES(5,'Queso',1000);
INSERT inTO PRODUCTO VALUES(6,'Sandia',8000);
INSERT inTO PRODUCTO VALUES(7,'Leche 1L',4563);
INSERT INTO PRODUCTO VALUES(8,'Atun',1800);
INSERT INTO PRODUCTO VALUES(9,'Pescado',7856);
INSERT INTO PRODUCTO VALUES(10,'Cicla Estatica',1800);
INSERT INTO PRODUCTO VALUES(11,'Camiseta',12000);
INSERT INTO PRODUCTO VALUES(12,'Blue-Jean',7800);
INSERT INTO PRODUCTO VALUES(13,'Papaya',1400);
INSERT INTO PRODUCTO VALUES(14,'Agua en Bolsa',1800);
INSERT INTO PRODUCTO VALUES(15,'Red Bull',1200);

---------------------------------------------------
--                  VENTA
---------------------------------------------------

INSERT INTO VENTA VALUES(1,5,123,1);
INSERT INTO VENTA VALUES(2,6,123,2);
INSERT INTO VENTA VALUES(3,7,123,3);
INSERT INTO VENTA VALUES(4,8,123,4);
INSERT INTO VENTA VALUES(5,2,456,5);
INSERT INTO VENTA VALUES(6,4,741,6);
INSERT INTO VENTA VALUES(7,5,456,7);
INSERT INTO VENTA VALUES(8,600,741,8);
INSERT INTO VENTA VALUES(9,69,852,9);
INSERT INTO VENTA VALUES(10,15,789,10);
INSERT INTO VENTA VALUES(11,11,456,5);
INSERT INTO VENTA VALUES(12,22,789,6);
INSERT INTO VENTA VALUES(13,11,753,7);
INSERT INTO VENTA VALUES(14,10,963,12);
INSERT INTO VENTA VALUES(15,65,963,11);
INSERT INTO VENTA VALUES(16,12,852,10);
INSERT INTO VENTA VALUES(17,65,741,9);
INSERT INTO VENTA VALUES(18,78,147,8);
INSERT INTO VENTA VALUES(19,92,258,9);
INSERT INTO VENTA VALUES(20,12,258,6);
INSERT INTO VENTA VALUES(21,32,147,3);
INSERT INTO VENTA VALUES(22,3,789,1);
INSERT INTO VENTA VALUES(23,45,456,2);
INSERT INTO VENTA VALUES(24,5,123,3);
INSERT INTO VENTA VALUES(25,5,789,4);
INSERT INTO VENTA VALUES(26,6,456,1);
INSERT INTO VENTA VALUES(27,4,123,2);
INSERT INTO VENTA VALUES(28,7,789,12);
INSERT INTO VENTA VALUES(29,8,258,13);
INSERT INTO VENTA VALUES(30,9,852,14);
INSERT INTO VENTA VALUES(31,9,753,15);
INSERT INTO VENTA VALUES(32,6,753,10);
INSERT INTO VENTA VALUES(33,7,159,9);
INSERT INTO VENTA VALUES(34,8,963,10);
INSERT INTO VENTA VALUES(35,9,369,8);
INSERT INTO VENTA VALUES(36,15,369,7);
INSERT INTO VENTA VALUES(37,5,123,5);
INSERT INTO VENTA VALUES(38,6,123,6);
INSERT INTO VENTA VALUES(39,7,123,7);
INSERT INTO VENTA VALUES(40,8,123,8);
INSERT INTO VENTA VALUES(41,5,123,9);
INSERT INTO VENTA VALUES(42,6,123,10);
INSERT INTO VENTA VALUES(43,7,123,11);
INSERT INTO VENTA VALUES(44,8,123,12);
INSERT INTO VENTA VALUES(45,5,123,13);
INSERT INTO VENTA VALUES(46,6,123,14);
INSERT INTO VENTA VALUES(47,7,123,15);


--------------------------------------------------------------------------------------------------------------------------------
--                  Formular SQL una consulta que muestre:
--------------------------------------------------------------------------------------------------------------------------------

/*
    1. Id de los clientes de Cali.
*/

select c.id_cliente from cliente c where c.ciudad = 'Cali';

/*
    2. Id y la descripción de los productos que cuesten menos de $1500 pesos.
*/

select p.id_producto, p.descripcion from producto p where p.precio < 1500;

/*
    3. Id y nombre de los clientes, cantidad vendida y la descripción del producto, en las ventas en las cuales se vendieron más de 10 unidades.
*/

select c.id_cliente, c.nombre, v.cantidad, p.descripcion from venta v
    inner join producto p on p.id_producto = v.id_producto
    inner join cliente c on c.id_cliente = v.id_cliente
    where v.cantidad  > 10
    group by c.id_cliente, c.nombre, v.cantidad, p.descripcion;

/*
    4. Id y nombre de los clientes que no aparecen en la tabla de ventas (Clientes que no han comprado productos).
*/

select c.id_cliente, c.nombre from cliente c 
    left join venta v on v.id_cliente = c.id_cliente
    where v.id_venta is null  
    group by c.id_cliente, c.nombre;

/*
    5. Id y nombre de los clientes que han comprado todos los productos de la empresa.
*/

select c.id_cliente, c.nombre from cliente c
    inner join venta v on v.id_cliente = c.id_cliente
    group by c.id_cliente, c.nombre
    having (select count(*) from producto) = count(distinct v.id_producto);

/*
    6. Id, nombre de cada cliente y la suma total (suma de cantidad) de los productos que ha comprado.
*/

select c.id_cliente, c.nombre, sum(v.cantidad) as total_productos from cliente c
    inner join venta v on c.id_cliente = v.id_cliente
    group by c.id_cliente, c.nombre

/*
    7. Id de los productos que no han sido comprados por clientes de Tunja.
*/

select p.id_producto from producto p 
	where p.id_producto not in (
		select p.id_producto from cliente c
			inner join venta v on v.id_cliente = c.id_cliente
		    inner join producto p on p.id_producto = v.id_producto
		    where c.ciudad = 'Tunja'
		)
	group  by p.id_producto;
    
select p.id_producto from producto p
    left join (
        select distinct v.id_producto from venta v
        inner join cliente c on v.id_cliente = c.id_cliente
        where c.ciudad = 'Tunja'
    ) t on p.id_producto = t.id_producto
    where t.id_producto is null;

/*
    8. Id de los productos que se han vendido a clientes de Medellín y que también se han vendido a clientes de Bogotá.
*/

select b.id_producto from
	(select p.id_producto from cliente c
		inner join venta v on v.id_cliente = c.id_cliente
	    inner join producto p on p.id_producto = v.id_producto
	    where c.ciudad = 'Bogota') b,
	    
	(select p.id_producto from cliente c
		inner join venta v on v.id_cliente = c.id_cliente
	    inner join producto p on p.id_producto = v.id_producto
	    where c.ciudad = 'Medellin') m
	where b.id_producto = m.id_producto
	group by b.id_producto, m.id_producto;
   
select v.id_producto from venta v
	where v.id_cliente in (select c.id_cliente from cliente c where c.ciudad = 'Medellin')
	  and v.id_producto in (
	  	select v.id_producto from venta v where v.id_cliente in (
			select c.id_cliente from cliente c where c.ciudad = 'Bogota'
			)
		)
	group by v.id_producto;


/*
    9. Nombre de las ciudades en las que se han vendido todos los productos.
*/

select c.ciudad from cliente c
    inner join venta v on v.id_cliente = c.id_cliente
    group by c.ciudad 
    having (select count(*) from producto) = count(distinct v.id_producto);

   
   
--
--
-- 

/*
   	 select p.id_producto from producto p 
	where p.id_producto not in (
	select p.id_producto from cliente c
		inner join venta v on v.id_cliente = c.id_cliente
	    inner join producto p on p.id_producto = v.id_producto
	    where c.ciudad = 'Tunja'
	)
select c.ciudad, p.id_producto, p.descripcion from cliente c
	inner join venta v on v.id_cliente = c.id_cliente
    inner join producto p on p.id_producto = v.id_producto
    where c.ciudad = 'Bogota' or c.ciudad = 'Medellin'
    group by c.ciudad, p.descripcion, p.id_producto 
   	order by c.ciudad;
 
select c.ciudad, p.id_producto, p.descripcion from cliente c
	inner join venta v on v.id_cliente = c.id_cliente
    
    inner join producto p on p.id_producto = v.id_producto
    where c.ciudad = 'Bogota' or c.ciudad = 'Medellin'
    group by c.ciudad, p.descripcion, p.id_producto 
   	order by c.ciudad;
 

   
    where c.ciudad = 'Tunja'
    group by c.ciudad, p.descripcion, p.id_producto;
   	
select c.ciudad, p.id_producto, p.descripcion from cliente c
	inner join venta v on v.id_cliente = c.id_cliente
    inner join producto p on p.id_producto = v.id_producto
    where c.ciudad = 'Bogota' or c.ciudad = 'Medellin'
    group by c.ciudad, p.descripcion, p.id_producto;
*/

   

CREATE OR REPLACE FUNCTION nombre_funcion()
RETURNS void AS $$
BEGIN
    -- Código del procedimiento almacenado
END;
$$ LANGUAGE plpgsql;

-----------------------------

create or replace procedure tratamientos_afiliado(in miCI varchar)
language 'plpgsql' as $$
	declare 
		 contador integer := 0;
	BEGIN
		RAISE NOTICE 'Los tratamientos realizados al afiliado con el CI es';
	    return;
	end;
$$;
    

SELECT pg_get_functiondef(p.oid)
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
INNER JOIN (
	SELECT routine_name
	FROM information_schema.routines
	WHERE (routine_type='FUNCTION' or routine_type='PROCEDURE') AND specific_schema='public'
) pr ON p.pronamespace = n.oid
WHERE n.nspname = 'public' -- Cambiar por el esquema donde se encuentra la función
AND p.proname = pr.routine_name; -- Cambiar por el nombre de la función

-----
create or replace FUNCTION get_code()
RETURNS void AS $$
	DECLARE
		factura record;
	BEGIN
	
		for factura in 
			SELECT pg_get_functiondef(p.oid) as code
			FROM pg_proc p
			INNER JOIN pg_namespace n ON p.pronamespace = n.oid
			INNER JOIN (
				SELECT routine_name FROM information_schema.routines
				WHERE (routine_type='FUNCTION' or routine_type='PROCEDURE') AND specific_schema='public'
			) pr ON p.pronamespace = n.oid
			WHERE n.nspname = 'public' AND p.proname = pr.routine_name
			
		loop
			raise notice 'Code: %', factura.code;
		end loop;
END;
$$ LANGUAGE plpgsql;

select get_code();



