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

select * from obtener_total_pedidos('ALFKI', 1997, 2);

/*
2. Elabore una función que elimine un determinado cliente, si éste no ha generado Pedido
alguno.
*/



/*
3. Crear un cursor que permita aumentar el precio unitario de un producto segunda la
siguiente tabla.
Proveedor 1 y Categoría 4 --- incrementar en 10%
Proveedor 3 y Categoría 2 --- incrementar en 15%
Proveedor 2 y Categoría 5 --- incrementar en 20%
*/



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



/*
5. Implementa una función que imprima todos los datos de un determinado empleado, con los
formatos sugeridos, si el dato fuera NULO, imprimir 0.
Además, debe calcular la comisión del vendedor, ingresada por parámetro externo (&=
30%) de la venta calculada de pedidos por vendedor
Dato de entrada: idempleado
Dato de salida:
Empleado - Cargo - Fecha Ingreso - Venta - Comisión
*/