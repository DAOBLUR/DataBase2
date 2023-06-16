/*
4. Construya un programa sql que devuelva la razón social, dirección y teléfono de abastecimiento de
los proveedores que abastecen un determinado producto.
*/
-- (ID PRODUNTO) => 1

select * from compras.proveedores p 
select * from compras.productos p2 order by p2.idproducto 

create or replace function obtener_producto_proveedores(in p_id compras.productos.idproducto%type, 
        out p_nombre compras.productos.nomproducto%type, out pr_razon_social compras.proveedores.nomproveedor%type,
        out pr_direccion compras.proveedores.dirproveedor%type, out pr_telefono compras.proveedores.fonoproveedor%type ) 
    returns setof record as
    $$
    declare
        cur cursor (p_id compras.productos.idproducto%type) for (
            select p.nomproducto, pr.nomproveedor, pr.dirproveedor, pr.fonoproveedor
            from compras.productos p
            join compras.proveedores pr on pr.idproveedor = p.idproveedor
            where p.idproducto = p_id
            group by p.nomproducto, pr.nomproveedor, pr.dirproveedor, pr.fonoproveedor
        );
        rec record;
    begin
        open cur(p_id);
        loop
            fetch cur into rec;
            exit when not found;

            p_nombre := rec.nomproducto;
            pr_razon_social := rec.nomproveedor;
            pr_direccion := rec.dirproveedor;
            pr_telefono := rec.fonoproveedor;

            return next;
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

select * from obtener_producto_proveedores(1);

---------------------------
-- (ID PROVEEDOR) => 0 - *

select * from compras.proveedores p 
select * from compras.productos p2 order by p2.idproveedor 

create or replace function obtener_proveedor_productos(in pr_id compras.proveedores.idproveedor%type, 
        out p_nombre compras.productos.nomproducto%type, out pr_razon_social compras.proveedores.nomproveedor%type,
        out pr_direccion compras.proveedores.dirproveedor%type, out pr_telefono compras.proveedores.fonoproveedor%type ) 
    returns setof record as
    $$
    declare
        cur cursor (pr_id compras.productos.idproducto%type) for (
            select p.nomproducto, pr.nomproveedor, pr.dirproveedor, pr.fonoproveedor
            from compras.productos p
            join compras.proveedores pr on pr.idproveedor = p.idproveedor
            where p.idproveedor = pr_id
            group by p.nomproducto, pr.nomproveedor, pr.dirproveedor, pr.fonoproveedor
        );
        rec record;
    begin
        open cur(pr_id);
        loop
            fetch cur into rec;
            exit when not found;

            p_nombre := rec.nomproducto;
            pr_razon_social := rec.nomproveedor;
            pr_direccion := rec.dirproveedor;
            pr_telefono := rec.fonoproveedor;

            return next;
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

select * from obtener_proveedor_productos(2);

/*
5. Elabore un programa sql que devuelva el total de órdenes generadas a un cliente en un
determinado trimestre de un determinado año.
*/

select p.idpedido, count(pd)
        from ventas.pedidoscabe p 
	    join ventas.pedidosdeta pd on pd.idpedido = p.idpedido 
	    group by p.idpedido 
	    

select count(pd), sum(pd.cantidad*(pd.preciounidad - (pd.preciounidad*descuento))) 
        from ventas.pedidoscabe p 
	    join ventas.pedidosdeta pd on pd.idpedido = p.idpedido 
	    where p.idcliente = 'ALFKI' and extract(year from p.fechapedido) = 1997
	        and extract(quarter from p.fechapedido) = 3
	      group by p.idpedido ;

create or replace function obtener_total_ordenes(inout c_id ventas.clientes.idcliente%type, 
    in p_anio int, in p_trimestre int, out ordenes int, out precio_total float) returns record as
$$
begin
	select count(pd), sum(pd.cantidad*(pd.preciounidad - (pd.preciounidad*descuento))) 
        from ventas.clientes c 
	    into ordenes, precio_total
	    join ventas.pedidoscabe p on p.idcliente = c.idcliente
	    join ventas.pedidosdeta pd on pd.idpedido = p.idpedido 
	    where c.idcliente = c_id and extract(year from p.fechapedido) = p_anio
	        and extract(quarter from p.fechapedido) = p_trimestre
	    group by p.idpedido;

exception
    when others then
        raise notice 'ERROR: %', SQLERRM;
        return;
end 
$$ 
language 'plpgsql';

select * from obtener_total_ordenes('ALFKI', 1997, 3);

select * from obtener_total_pedidos('ALFKI', 1997, 3);


/*
6. Elabore un programa sql que devuelva en qué pedido, fechas y qué razón social de cliente han
adquirido un determinado producto.
*/


