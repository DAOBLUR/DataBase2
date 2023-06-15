--create database ev2ejercicio4;

create table sucursal (
	cod_sucursal int not null primary key, 
	nombre varchar(30) not null,
	direccion varchar(30) not null,
	localidad varchar(20) not null
);

create table cuenta (
    cod_cuenta int not null,
    cod_sucursal int not null references sucursal,
    primary key(cod_cuenta, cod_sucursal) 
);

create table cliente (
    dni varchar(8) not null primary key,
    nombre varchar(30) not null,
    direccion varchar(30) not null,
    localidad varchar(20) not null,
    fecha_nac date not null,
    sexo varchar(2) not null
);

create table cliente_cuenta (
    cod_cuenta int not null,
    cod_sucursal int not null,
    dni_cliente varchar(8) not null references cliente,
    foreign key (cod_cuenta, cod_sucursal) references cuenta,
    primary key(cod_cuenta, cod_sucursal, dni_cliente) 
);

create table transaccion (
    num_transaccion int not null,
    fecha date not null,
    cantidad float not null,
    cod_cuenta int not null,
    cod_sucursal int not null,
    foreign key (cod_cuenta, cod_sucursal) references cuenta,
    primary key(num_transaccion, cod_cuenta, cod_sucursal)
);