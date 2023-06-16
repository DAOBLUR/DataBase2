/*
1. Elabore una función que devuelva el total de pedidos generados a un cliente en un
determinado trimestre de un determinado año.
*/

select * from ventas.clientes c 
select * from ventas.pedidoscabe p  
select * from ventas.pedidosdeta p2 

create or replace function obtener_total_pedidos(inout c_id ventas.clientes.idcliente%type, 
    in p_anio int, in p_trimestre int, out pedidos int, out precio_total float) returns record as
$$
begin
	select count(p.idpedido), sum(pd.cantidad*(pd.preciounidad - (pd.preciounidad*descuento))) 
        from ventas.clientes c 
	    into pedidos, precio_total
	    join ventas.pedidoscabe p on p.idcliente = c.idcliente
	    join ventas.pedidosdeta pd on pd.idpedido = p.idpedido 
	    where c.idcliente = c_id and extract(year from p.fechapedido) = p_anio
	        and extract(quarter from p.fechapedido) = p_trimestre;

exception
    when others then
        raise notice 'ERROR: %', SQLERRM;
        return;
end 
$$ 
language 'plpgsql';

select * from obtener_total_pedidos('ALFKI', 1997, 3);

/*
2. Elabore una función que elimine un determinado cliente, si éste no ha generado Pedido
alguno.
*/

select * from ventas.clientes c

insert into ventas.clientes values('NEW1', 'nombre 1',  '265, boulevard Charonne', '008','(1); 42.34.22.77');
insert into ventas.clientes values('NEW2', 'nombre 2',  '265, boulevard Charonne', '008','(1); 42.34.22.77');

create or replace function eliminar_cliente_sin_pedidos(c_id ventas.clientes.idcliente%type)
returns void as 
$$
begin
	delete from ventas.clientes where idcliente = c_id and 
	idcliente in ( select c.idcliente from Ventas.clientes c
		left join ventas.pedidoscabe p on c.IdCliente = p.IdCliente
		where p.IdPedido is null );
end;
$$ 
language plpgsql;

select eliminar_cliente_sin_pedidos('NEW1');

--------------------------------------------

create or replace function eliminar_cliente_sin_pedidos2(c_id ventas.clientes.idcliente%type)
returns void as 
$$
begin
    if not exists (
        select * from ventas.pedidoscabe where idcliente = c_id limit 1
    ) 
	then
        delete from ventas.clientes where idcliente = c_id;
        raise notice 'cliente eliminado: %', c_id;
    else
        raise notice 'no puede ser eliminado: %', c_id;
    end if;
end;
$$ 
language plpgsql;

select eliminar_cliente_sin_pedidos2('FISSA');

/*
3. Crear un cursor que permita aumentar el precio unitario de un producto segunda la
siguiente tabla.
Proveedor 1 y Categoría 4 --- incrementar en 10%
Proveedor 3 y Categoría 2 --- incrementar en 15%
Proveedor 2 y Categoría 5 --- incrementar en 20%
*/

select * from compras.productos p 
select * from compras.proveedores p2  
select * from compras.categorias c 

create or replace procedure aumentar_precio_unitario()
language plpgsql as 
$procedure$
declare
    cur cursor for ( select p.* from compras.productos p
        join compras.proveedores pr on pr.idproveedor = p.idproveedor
        join compras.categorias c on c.idcateria = p.idcateria
        where p.idproveedor in ( 1,2,3 ) and p.idcateria in ( 2,4,5 )
        group by p.idproducto
    );
    rec record;
begin
    open cur;
    loop
        fetch cur into rec;
        exit when not found;
        if rec.idproveedor = 1 and rec.idcateria = 4 then
        	raise notice 'update: %', rec.preciounidad * (1 + 0.1);
            update compras.productos set preciounidad = rec.preciounidad * (1 + 0.1)
            where idproducto = rec.idproducto;
        elsif rec.idproveedor = 3 and rec.idcateria = 2 then
        	raise notice 'update: %', rec.preciounidad * (1 + 0.15);
            update compras.productos set preciounidad = rec.preciounidad * (1 + 0.15)
            where idproducto = rec.idproducto;
        elsif rec.idproveedor = 2 and rec.idcateria = 5 then
        	raise notice 'update: %', rec.preciounidad * (1 + 0.2);
            update compras.productos set preciounidad = rec.preciounidad * (1 + 0.2)
            where idproducto = rec.idproducto;
        end if;
    end loop;
    close cur;
exception
    when others then
        raise notice 'ERROR: %', SQLERRM;
        rollback;
        return;
end;
$procedure$;

call aumentar_precio_unitario();

/*
4. Listar los empleados por puesto de trabajo
Puesto: AAAAAA
Empleado 1

Producto vendido1
Producto vendido2

Empleado 2

Producto vendido1
Producto vendido2

Puesto: BBBBB
Empleado7

Producto vendido1
Producto vendido2
*/

select * from rrhh.empleados e 
select * from rrhh.cargos c 
select * from ventas.pedidoscabe p order by p.idempleado  
select * from ventas.pedidosdeta p2 order by p2.idproducto 
select * from compras.productos p3 order by p3.idproducto
---------
    
select e.idempleado, c.descargo, count(distinct p.idproducto) as cantidad_productos_vendidos
	from rrhh.cargos c
	join rrhh.empleados e on e.idcargo = c.idcargo
	join ventas.pedidoscabe pc on pc.idempleado = e.idempleado
	join ventas.pedidosdeta pd on pc.idpedido = pd.idpedido
	join compras.productos p on p.idproducto = pd.idproducto
	group by e.idempleado, c.descargo 
	order by c.descargo, e.idempleado;

---------
create or replace function mostrar_cargo_empleado_ventas() 
returns void as 
$$
declare
    cur_cargos cursor for ( select * from rrhh.cargos );
    rec_cargos record;
begin
    open cur_cargos;
    loop
        fetch cur_cargos into rec_cargos;
        exit when not found;
        raise notice '* CARGO: % , %', rec_cargos.idcargo, rec_cargos.descargo;

        declare
            cur_empleados cursor for ( select e.idempleado, e.apeempleado, e.nomempleado 
                from rrhh.empleados e where e.idcargo = rec_cargos.idcargo
            );
            rec_empleados record;
        begin
            open cur_empleados;
            loop
                fetch cur_empleados into rec_empleados;
                exit when not found;
                raise notice '  + EMPLEADO: % , % %', 
                    rec_empleados.idempleado, rec_empleados.nomempleado, rec_empleados.apeempleado;
                
                declare
                    cur_productos cursor for ( select p.idproducto, p.nomproducto
                        from compras.productos p 
                        join ventas.pedidosdeta pd on pd.idproducto = p.idproducto
                        join ventas.pedidoscabe pc on pc.idpedido = pd.idpedido
                        where pc.idempleado = rec_empleados.idempleado
                        group by p.idproducto, p.nomproducto
                        order by p.idproducto
                    );
                    rec_productos record;
                    producto_count int;
                begin
                    producto_count := 1;
                    open cur_productos;
                    loop
                        fetch cur_productos into rec_productos;
                        exit when not found;
                        raise notice '	  - PRODUCTO VENDIDO (%): % , %', producto_count, rec_productos.idproducto, rec_productos.nomproducto;
                        producto_count := producto_count + 1;
                    end loop;
                    close cur_productos;
                end;
            end loop;
            close cur_empleados;
        end;
    end loop;
    close cur_cargos;
    return;
exception
    when others then
        raise notice 'ERROR: %', SQLERRM;
        return;
end;
$$
LANGUAGE plpgsql;

select mostrar_cargo_empleado_ventas();

/*
5. Implementa una función que imprima todos los datos de un determinado empleado, con los
formatos sugeridos, si el dato fuera NULO, imprimir 0.

Además, debe calcular la comisión del vendedor, ingresada por parámetro externo (&=
30%) de la venta calculada de pedidos por vendedor

Dato de entrada: idempleado

Dato de salida:
Empleado - Cargo - Fecha Ingreso - Venta - Comisión
*/

select * from rrhh.empleados e 
select * from ventas.pedidoscabe p order by p.idempleado  
select * from ventas.pedidosdeta p2 order by p2.idproducto 
select * from compras.productos p3 order by p3.idproducto


create or replace function mostrar_empleado_comision(
    in e_id rrhh.empleados.idempleado%type, in e_comision int) 
returns void as 
$$
declare
    empleado_nombre rrhh.empleados.nomempleado%type;
    empleado_apellido rrhh.empleados.apeempleado%type;
    empleado_cargo rrhh.cargos.descargo%type;
    empleado_fecha_ingreso rrhh.empleados.feccontrata%type;
    empleado_ventas float;
begin

    select e.nomempleado, e.apeempleado, c.descargo, e.feccontrata,
        sum(pd.cantidad*(pd.preciounidad - (pd.preciounidad*descuento)))
    into empleado_nombre, empleado_apellido, empleado_cargo, empleado_fecha_ingreso, empleado_ventas
    from rrhh.cargos c
    join rrhh.empleados e on e.idcargo = c.idcargo
    join ventas.pedidoscabe pc on pc.idempleado = e.idempleado
    join ventas.pedidosdeta pd on pc.idpedido = pd.idpedido
    where e.idempleado = e_id
   group by e.nomempleado, e.apeempleado, c.descargo, e.feccontrata;
    
	if empleado_nombre is null or empleado_apellido is null or empleado_cargo is null or 
		empleado_fecha_ingreso is null or empleado_ventas is null then
        	raise notice '0';
    else
        raise notice '% % - % - % - % - %', empleado_nombre, empleado_apellido, empleado_cargo, 
            empleado_fecha_ingreso, empleado_ventas, (empleado_ventas * (e_comision/100.0));
    end if;
    return;
exception
    when others then
        raise notice 'ERROR: %', SQLERRM;
        return;
end;
$$
language plpgsql;

select mostrar_empleado_comision(1,10);
select mostrar_empleado_comision(10,10);