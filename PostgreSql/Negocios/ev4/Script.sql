/*
4. Realizar un análisis de la estructura y datos de la Base de datos Negocios (diccionario de
datos) listado las tablas, columnas, restricciones, vistas, funciones, procedimientos y
detonadores mostrando las sentencias que construyen las vistas, funciones y
procedimientos además del estado de los detonadores
*/
--listado de tablas
create or replace view Seleccionar_Tablas as
    select table_name as Tabla from information_schema.columns
	where table_schema in ('compras','rrhh','ventas','public') group by table_name;

select * from Seleccionar_Tablas;

--listado de columnas por tablas
create or replace view Seleccionar_Columnas as
	select table_name as tabla, column_name as columna, data_type as tipo_de_dato
	    from information_schema.columns
        where table_schema in ('compras', 'rrhh', 'ventas', 'public')
		    and table_name not in (
		        select table_name from information_schema.views
		        where table_schema in ('compras', 'rrhh', 'ventas', 'public')
		    )
		order by table_name, ordinal_position;

select * from Seleccionar_Columnas;

--listado de Restricciones por Columnas

create or replace view Seleccionar_Restricciones_Columnas as
	select tc.table_name as tabla, kcu.column_name as columna, 
			tc.constraint_name as restriccion, tc.constraint_type as tipo_restriccion
		from information_schema.table_constraints tc
		join information_schema.constraint_column_usage as ccu on tc.constraint_name = ccu.constraint_name
		join information_schema.key_column_usage as kcu on ccu.constraint_name = kcu.constraint_name
		where tc.constraint_schema in ('compras', 'rrhh', 'ventas', 'public')	
		order by tc.constraint_schema, tc.table_name;

select * from Seleccionar_Restricciones_Columnas;

--listado de Vistas

create or replace view Seleccionar_Vistas as
	select c.table_name as vista, v.view_definition as definicion
		from information_schema.columns as c
		join information_schema.views as v on c.table_name = v.table_name
		where c.table_schema in ('compras', 'rrhh', 'ventas', 'public')
		order by c.table_name, c.ordinal_position;

select * from Seleccionar_Vistas;

--lista de funciones y procedimientos

create or replace view Seleccionar_Funciones_Procedimientos as
	select pg_get_functiondef(p.oid) from pg_proc p
	    join pg_namespace n on p.pronamespace = n.oid
	    where n.nspname in ('compras','rrhh','ventas','public') and p.proname = 'rewards_report';
	    select p."oid" ,p.proname, pr.routine_type, p.prosrc from pg_proc p
	        join pg_namespace n ON p.pronamespace = n.oid
	        join (
	            select routine_name, routine_type from information_schema.routines
	            where routine_type in ('FUNCTION','PROCEDURE') and specific_schema in ('compras','rrhh','ventas','public')
	        ) 
	        pr on p.pronamespace = n.oid
	    where n.nspname in ('compras','rrhh','ventas','public')
	    and p.proname = pr.routine_name;

select * from Seleccionar_Funciones_Procedimientos;

--
SELECT event_object_schema as table_schema,
       event_object_table as table_name,
       trigger_schema,
       trigger_name,
       string_agg(event_manipulation, ',') as event,
       action_timing as activation,
       action_condition as condition,
       action_statement as definition
FROM information_schema.triggers
GROUP BY 1, 2, 3, 4, 6, 7, 8
ORDER BY table_schema, table_name;


/*
5. La empresa necesita modificar las reglas de negocio donde se nos pide
*/
--a. Implementar una planilla de pagos salariales para los empleado
--b. La planilla debe ser construida de forma particionada para que se consulte las planillas de cada 5 años
--c. Los empleados recibirán un salario según las siguientes condiciones
------i. Planilla Mensual
------ii. Sueldo base 1500 a todos los empleados
alter table rrhh.empleados add column sueldo_base float;

create or replace procedure rrhh.Actualizar_Sueldo_Base(in e_sueldo_base rrhh.empleados.sueldo_base%type)
language plpgsql
as $procedure$
declare
    rec record;
begin
    for rec in (
        select e.idempleado from rrhh.empleados e
    )
    loop
        update rrhh.empleados set sueldo_base = e_sueldo_base where idempleado = rec.idempleado;
    end loop;
    commit;
end;
$procedure$;

call rrhh.Actualizar_Sueldo_Base(1500);

------iii. Bonificación por movilidad 200 para los Representante de Ventas y Ejecutivo de Venta
alter table rrhh.cargos add column bonificacion float;

create or replace procedure rrhh.Actualizar_Bonificacion(
    in c_id rrhh.cargos.idcargo%type, in c_bonificacion rrhh.cargos.bonificacion%type)
language plpgsql
as $procedure$
begin
    update rrhh.cargos set bonificacion = bonificacion + c_bonificacion where idcargo = c_id;
    commit;
end;
$procedure$;

call rrhh.Actualizar_Bonificacion(1,200);
call rrhh.Actualizar_Bonificacion(2,2000);

------iv. Asignación familiar ( 102.5 a los trabajadores que tienen hijos menores de 18 años)
/*
select c.nombrecateria, c.descripcion  from compras.categorias c

select * from rrhh.distritos
select * from rrhh.empleados
select * from rrhh.cargos
select * from rrhh.Hijos
select * from ventas.pedidosdeta
*/

alter table rrhh.empleados add column bonificacion float;

create table rrhh.Hijos (
    id int not null primary key,
    idempleado int not null references rrhh.empleados,
    fecha_nacimiento date not null,
    nombre varchar(25) not null
);

insert into rrhh.Hijos values (1, 1, '01-15-2000','Pedro');
insert into rrhh.Hijos values (2, 2, '11-15-2000','Pablo');
insert into rrhh.Hijos values (3, 3, '03-15-2010','Ricardo');
insert into rrhh.Hijos values (4, 4, '05-15-2015','Elena');

create or replace procedure rrhh.Actualizar_Bonificacion_Familiar(in e_bonificacion rrhh.empleados.sueldo_base%type)
language plpgsql
as $$
declare
    rec record;
begin
    for rec in (
        select e.idempleado
	        from rrhh.empleados e
	        inner join rrhh.hijos h on e.idempleado = h.idempleado
	        where date_part('year', age(current_date, h.fecha_nacimiento)) < 18
	        group by e.idempleado, h.fecha_nacimiento
    )
    loop
        update rrhh.empleados set sueldo_base = sueldo_base + e_bonificacion where idempleado = rec.idempleado;
    end loop;
    
    commit;
end;
$$;


call rrhh.Actualizar_Bonificacion_Familiar(102.5);

------v. Porcentaje de Comisión por ventas depende de la antigüedad del
--trabajador y el cargo permiten el cálculo del monto de comisión (función)
create table rrhh.Comision (
    anio int not null,
    cargo int references rrhh.cargos,
    comision int not null
);
--todos
insert into rrhh.Comision values (2010, 1, 15);
insert into rrhh.Comision values (2010, 2, 15);
insert into rrhh.Comision values (2010, 3, 15);
insert into rrhh.Comision values (2010, 4, 15);
--
insert into rrhh.Comision values (2011, 3, 10);
insert into rrhh.Comision values (2011, 4, 5);
--otros
insert into rrhh.Comision values (2011, 1, 0);
insert into rrhh.Comision values (2011, 2, 0);
--
CREATE OR REPLACE FUNCTION CalcularMontoComision(in e_id rrhh.empleados.idempleado%type)
RETURNS FLOAT AS $$
DECLARE
    monto_comision FLOAT;
BEGIN
    SELECT SUM(d.cantidad * c.comision * (d.preciounidad * (1.0 - d.descuento))) INTO monto_comision
    FROM rrhh.empleados e
    JOIN rrhh.comision c ON c.cargo = e.idcargo AND c.anio = extract('year' from e.feccontrata)
    JOIN ventas.pedidoscabe p ON p.idempleado = e.idempleado
    JOIN ventas.pedidosdeta d ON d.idpedido = p.idpedido
    WHERE e.idempleado = e_id;
    
    IF monto_comision IS NULL THEN
        RAISE NOTICE 'No se encontró un empleado con el ID %', e_id;
    END IF;
    
    RETURN monto_comision * 1.0;
END;
$$ LANGUAGE plpgsql;

SELECT CalcularMontoComision(1);

------vi. Existirán varias planillas en el sistema. Existirán varias planillas en el sistema
create table rrhh.Planilla (
    codigo int not null primary key,
    periodo varchar(15) not null,
    planilla varchar(15) not null
);

insert into rrhh.Comision values (1, 'Mensual', 'Mensual');
insert into rrhh.Comision values (2, 'Semestral', 'Gratificacion');
insert into rrhh.Comision values (3, 'Cese', 'Liquidación');
insert into rrhh.Comision values (4, 'May-Nov', 'CTS');
insert into rrhh.Comision values (5, 'Enero', 'Vacaciones');
insert into rrhh.Comision values (6, 'Marzo', 'Utilidades');

------vii. Implementar los descuentos del trabajador por tipo de pensión:
--Sistema privado del fondo de pensiones (AFP) descuentoAFP = 9% del SB
--Sistema nacional de pensiones (ONP) descuentoONP = 8% del SB

------viii. Aportes del Empleador Essalud = 9%
------ix. Se solicita implementar la planilla mensual hasta la emisión de la boleta según :
--d. Toda consulta debe ser creada como vista
--e. Todo proceso como función
/*
6. Tareas:
*/
--a. Se debe implementar un proceso para cesar a los trabajadores y una tarea
--automática que siendo las 11:55 pm todos los días realice el cambie el estado de
--ACTIVO ha CESADO en el registro del trabajador

alter table rrhh.empleados add column estado varchar(6);

--b. El trabajador cuando es cesado debe guardarse sus datos en la tabla de auditoria
--HISTORICO_EMPLEADOS además del nombre del usuario que lo ceso y la fecha de
--cese. (detonadores)
create schema auditoria;

create table auditoria.historico_empleados (
	idempleado int4 not null,
	apeempleado varchar(50) not null,
	nomempleado varchar(50) not null,
	fecnac timestamp not null,
	dirempleado varchar(60) not null,
	iddistrito int4 null references rrhh.distritos(iddistrito),
	fonoempleado varchar(15) null,
	idcargo int4 null references rrhh.cargos,
	feccontrata timestamp not null,
	sueldo_base float8 null,
    log_movimiento  VARCHAR(10),
    log_fecha_mov   timestamp
);

CREATE OR REPLACE FUNCTION auditoria.tg_historico_empleados() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
        INSERT INTO auditoria.historico_empleados VALUES 
        (new.idempleado, new.apeempleado, new.nomempleado, new.fecnac, new.dirempleado, new.iddistrito, 
            new.fonoempleado, new.idcargo, new.feccontrata, new.sueldo_base, TG_OP, CURRENT_TIMESTAMP);
        RETURN new;
    END IF;

    IF (TG_OP='DELETE') THEN
        INSERT INTO auditoria.historico_empleados VALUES
        (old.idempleado, old.apeempleado, old.nomempleado, old.fecnac, old.dirempleado, old.iddistrito, 
            old.fonoempleado, old.idcargo, old.feccontrata, old.sueldo_base, TG_OP, CURRENT_TIMESTAMP);
    RETURN old;
    END IF;
END;
$BODY$ LANGUAGE 'plpgsql';

CREATE TRIGGER tg_historico_empleados AFTER INSERT OR UPDATE OR DELETE
ON rrhh.empleados FOR EACH ROW EXECUTE PROCEDURE auditoria.tg_historico_empleados();

select * from rrhh.empleados

INSERT INTO RRHH.empleados VALUES(109, 'NameEx', 'ApeEx', '1969-07-02 00:00:00', 'Av',3,'98877888',1,'2011-07-10',0,0);

/*
7. Se debe conectar la base de datos a un lenguaje de programación y una de las siguientes
actividades
*/
--a. Realizar un mantenimiento a una tabla maestro (ingresar, actualizar y eliminar registros de cualquiera tabla)
select * from rrhh.distritos
select * from rrhh.empleados
select * from rrhh.cargos
select * from rrhh.Hijos

create sequence sec_cargos;
select setval('sec_cargos', 5, false);

create or replace procedure rrhh.Insertar_Cargo(
	in c_descargo rrhh.cargos.descargo%type, in c_bonificacion rrhh.cargos.bonificacion%type)
language plpgsql
as $procedure$
begin
	insert into rrhh.Cargos values (nextval('sec_cargos'),c_descargo,c_bonificacion);
    commit;
end;
$procedure$;

call rrhh.Insertar_Cargo('none',0);

--
create or replace procedure rrhh.Actualizar_Cargo(in c_id rrhh.cargos.idcargo%type,
        in c_descargo rrhh.cargos.descargo%type, in c_bonificacion rrhh.cargos.bonificacion%type)
    language plpgsql
    as $procedure$
    begin
        update rrhh.Cargos set descargo = c_descargo, bonificacion = c_bonificacion
        where idcargo = c_id;
        commit;
    end;
    $procedure$;

    call rrhh.Actualizar_Cargo(5,'none',0);

    --
    create or replace procedure rrhh.Eliminar_Cargo(in c_id rrhh.cargos.idcargo%type)
    language plpgsql
    as $procedure$
    begin
        delete from rrhh.Cargos where idcargo = c_id;
        commit;
    end;
    $procedure$;

call rrhh.Eliminar_Cargo(5);

--b. Diseñar y ejecutar una consulta de muchas tablas (mínimo 5 tablas)
--c. Diseñar y ejecutar un reporte (usando un cursor anidado)
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
8. Crear una tarea automática para realizar la copia de seguridad de las bases de datos
de negocios después de los cambios programando todos los días a las 10 pm. 
*/

--"E:\Program Files\PostgreSQL\13\bin\pg_dump.exe" -U postgres -d negocios -f "E:\universidad\semester6\DatabaseII\PostgreSql\Negocios\ev4\backup.sql"
