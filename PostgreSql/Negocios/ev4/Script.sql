select c.nombrecateria, c.descripcion  from compras.categorias c

select * from rrhh.distritos
select * from rrhh.empleados
select * from rrhh.cargos

SELECT table_name, column_name, data_type
	FROM information_schema.columns
	WHERE table_schema = 'compras'
	ORDER BY table_name, ordinal_position;

SELECT table_name, column_name, data_type
	FROM information_schema.columns
	WHERE table_schema = 'rrhh'
	ORDER BY table_name, ordinal_position;

SELECT table_name, column_name, data_type
	FROM information_schema.columns
	WHERE table_schema = 'ventas'
	ORDER BY table_name, ordinal_position;

SELECT conname AS constraintt, conrelid::regclass AS table_name,
	contype AS constraint_type,
	pg_get_constraintdef(c.oid) AS constraint_definition
	FROM pg_constraint c ORDER BY constraint_type;


SELECT pg_get_functiondef(p.oid)
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname in ('compras','rrhh','ventas')
AND p.proname = 'rewards_report';
SELECT *
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
INNER JOIN (
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_type in ('FUNCTION','PROCEDURE') AND specific_schema in ('compras','rrhh','ventas')
) pr ON p.pronamespace = n.oid
WHERE n.nspname in ('compras','rrhh','ventas')
AND p.proname = pr.routine_name;
/*
Sueldo bbase
*/
alter table rrhh.empleados add column sueldo_base float;

create or replace procedure rrhh.Update_Sueldo_Base(in e_sueldo_base rrhh.empleados.sueldo_base%type)
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

call Update_Sueldo_Base(1500);

/*
5. La empresa necesita modificar las reglas de negocio donde se nos pide:
*/

--Porcentaje de Comisión por ventas depende de la antigüedad del 
--trabajador y el cargo permiten el cálculo del monto de comisión
--Monto de comisión: total vendido en el mes * % comisión
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

--Existirán varias planillas en el sistema
create table rrhh.Planilla (
    codigo int not null primary key,
    periodo varchar(15) not null,
    planilla varchar(15) not null
);

create view 