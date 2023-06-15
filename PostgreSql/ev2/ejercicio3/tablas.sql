--create database ev2ejercicio3;

create table municipio (
	id int not null primary key, 
	nombre varchar(30) not null,
	cod_postal varchar(5) not null,
	provincia varchar(20) not null
);

create table persona (
	dni varchar(8) int not null primary key,
	fecha_nac date not null,
	sexo varchar(2) not null,
	nombre varchar(30) not null,
);

create table vivienda (
	id int not null primary key, 
	tipo_via varchar(20) not null,
	nombre_via varchar(30) not null,
	numero int not null,
	id_municipio int not null references municipio,
	id_cabeza_fam int not null references persona
);

alter table persona add column id_vivienda int references vivienda;

create table propiedad (
	id_vivienda int not null references vivienda,
	id_persona int not null references persona,
	primary key(id_vivienda, id_persona)
);