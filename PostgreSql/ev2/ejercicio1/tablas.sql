--create database ejercicio1;

create table ALUMNO (
	Num_Matricula int not null primary key, 
	Nombre varchar(30) not null, 
	FechaNacimiento date not null, 
	Telefono varchar(9) not null
);

create table PROFESOR (
	Id_P int not null primary key, 
	NIF_P varchar(8) not null, 
	Nombre varchar(30) not null, 
	Especialidad varchar(30) not null, 
	Telefono varchar(9) not null
);

create table ASIGNATURA (
	Codigo_asignatura int not null primary key, 
	Id_Profesor int not null references PROFESOR, 
	Nombre varchar(30) not null,
	Numero_estudiantes int not null
);

create table MATRICULA (
	Num_Matricula int not null references ALUMNO,
	Codigo_asignatura int not null references ASIGNATURA,
	CusrsoEscolar varchar(30) not null,
	primary key(Num_Matricula, Codigo_asignatura) 
);

