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
	    
select p.*--, count(p)
        from ventas.pedidoscabe p 
	    where p.idcliente = 'ALFKI' and extract(year from p.fechapedido) = 1997
	        and extract(quarter from p.fechapedido) = 3


select pd.* from ventas.pedidosdeta pd 
	where pd.idpedido = 10643
	    
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


/*
6. Elabore un programa sql que devuelva en qué pedido, fechas y qué razón social de cliente han
adquirido un determinado producto.
*/
select * from ventas.clientes
select * from ventas.pedidoscabe p order by p.idcliente
select * from compras.productos p 

select pc.idpedido, pd.idproducto  
from ventas.pedidoscabe pc 
join ventas.pedidosdeta pd on pd.idpedido = pc.idpedido
where pc.idcliente = 'ALFKI'
group by pc.idpedido, pd.idproducto  
order by pc.idpedido, pd.idproducto  


select p.nomproducto, pc.idpedido, pc.fechapedido, pr.nomproveedor
    from ventas.pedidoscabe pc
    join ventas.pedidosdeta pd on pd.idpedido = pc.idpedido
    join compras.productos p on p.idproducto = pd.idproducto
    join compras.proveedores pr on pr.idproveedor = p.idproveedor
    where pc.idcliente = 'ALFKI' and p.idproducto = 5
    group by pc.idpedido, p.nomproducto, pc.fechapedido, pr.nomproveedor


create or replace function obtener_cliente_producto(
        in c_id ventas.clientes.idcliente%type, in p_id compras.productos.idproducto%type,
        out p_nombre compras.productos.nomproducto%type, out pc_id ventas.pedidoscabe.idpedido%type, 
        out pc_fecha ventas.pedidoscabe.fechapedido%type, out pr_razon_social compras.proveedores.nomproveedor%type) 
    returns setof record as
    $$
    declare
        cur cursor (c_id ventas.clientes.idcliente%type, p_id compras.productos.idproducto%type) 
            for (
                select p.nomproducto, pc.idpedido, pc.fechapedido, pr.nomproveedor
                    from ventas.clientes c
                    join ventas.pedidoscabe pc on pc.idcliente = c.idcliente
                    join ventas.pedidosdeta pd on pd.idpedido = pc.idpedido
                    join compras.productos p on p.idproducto = pd.idproducto
                    join compras.proveedores pr on pr.idproveedor = p.idproveedor
                    where c.idcliente = c_id and p.idproducto = p_id
                    group by pc.idpedido, p.nomproducto, pc.fechapedido, pr.nomproveedor
        );
        rec record;
    begin
        open cur(c_id,p_id);
        loop
            fetch cur into rec;
            exit when not found;

            p_nombre := rec.nomproducto;
            pc_id := rec.idpedido;
            pc_fecha := rec.fechapedido;
            pr_razon_social := rec.nomproveedor;

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

select * from obtener_cliente_producto('ALFKI',3);
select * from obtener_cliente_producto('ALFKI',5);
select * from obtener_cliente_producto('ALFKI',7);
select * from obtener_cliente_producto('ALFKI',8);
