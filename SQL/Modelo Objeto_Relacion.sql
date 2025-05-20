/*Recordar: la cardinalidad de una relacion es el maximo valor de cada una de las partes
OBS: En este caso solicita usar arreglos para los campos multivaluados por lo que podemos saltar el paso 6 de conversion de entidad relacion a relacional*/
/*Ejercicio 1: implementacion de la tabla: */
CREATE TYPE domicilio AS
(
	calle VARCHAR(50),
	nro SMALLINT,
	ciudad VARCHAR(100),
	provincia VARCHAR(50)
);

CREATE TYPE cargo AS ENUM (
	'administrativo', 'vendedor', 'cajero', 'gerente'
);

CREATE TYPE sector AS ENUM (
	'ventas', 'compras', 'gerencia', 'deposito'
);

CREATE TYPE categoria AS ENUM (
	'lacteos', 'carnes', 'bebidas', 'cereales'
);

CREATE TABLE persona (
	id_persona INTEGER NOT NULL,
	nombre VARCHAR (100),
	dni VARCHAR (9),
	domicilio domicilio,
	telefono VARCHAR(15)[],
	email VARCHAR(100)[],
	CONSTRAINT pk_persona PRIMARY KEY (id_persona)
);


CREATE TABLE empleado (
	cargo cargo, 
	sector sector,
	legajo SMALLINT,
	sueldo NUMERIC (8,2),
	CONSTRAINT pk_empleado PRIMARY KEY (id_persona)
)INHERITS(persona);

CREATE TABLE cliente (
	cta_cte VARCHAR(25),
	CONSTRAINT pk_cliente PRIMARY KEY (id_persona)
)INHERITS(persona);


CREATE TABLE pedido (
	id_pedido BIGINT NOT NULL,
	id_empleado INTEGER,
	id_cliente INTEGER,
	fecha date,
	total NUMERIC (8,2),
	CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
	CONSTRAINT fk_pedido_cl FOREIGN KEY (id_cliente)
		REFERENCES cliente(id_persona) MATCH SIMPLE
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	CONSTRAINT fk_pedido FOREIGN KEY (id_empleado)
		REFERENCES empleado(id_persona) MATCH SIMPLE
		ON UPDATE CASCADE
		ON DELETE NO ACTION
);

CREATE TABLE producto (
	id_producto INTEGER NOT NULL,
	nombre VARCHAR(50),
	descripcion VARCHAR(200),
	categoria categoria,
	precio NUMERIC (8,2),
	proveedor VARCHAR(100)[],
	CONSTRAINT pk_producto PRIMARY KEY (id_producto)
);

CREATE TABLE tiene (
	id_pedido BIGINT NOT NULL,
	id_producto INTEGER NOT NULL,
	cantidad SMALLINT,
	precio NUMERIC (8,2),
	CONSTRAINT pk_tiene PRIMARY KEY (id_pedido, id_producto),
	CONSTRAINT fk_tiene_pedido FOREIGN KEY (id_pedido) 
		REFERENCES pedido(id_pedido) MATCH SIMPLE
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	CONSTRAINT fk_tiene_producto FOREIGN KEY (id_producto) 
		REFERENCES producto(id_producto) MATCH SIMPLE
		ON UPDATE CASCADE
		ON DELETE NO ACTION
);

/*Tabla empleado*/
/*Para insertar datos con un tipo de datos compuesto se usa:
	ROW (...)
	Y para insertar en un campo de arreglo se usa:
	array[...]
*/
BEGIN TRANSACTION;
	INSERT INTO empleado VALUES (1, 'VILCARROMERO ERICK', '17130935',ROW('AV SANTA ROSA', 1177, 'S.M.TUC', 'TUCUMAN'), array['4319842', '4245554', '4444444','381555414'], array['vil@gmail.com', 'vilco@live.com'], 'cajero', 'ventas', 1232, 150000);
	select * from empleado;
	select * from ONLY persona;
COMMIT;
rollback;


/*Aclaracion interesante: Las columnas insertadas en la tabla hija no se veran reflejadas en la padre, pero si hacemos un SELECT sobre la tabla padre, si no colocamos un ONLY, esta recuperara los datos de la tabla hija*/
/*Por el contrario si se agrega un registro en la tabla “padre”, persona, no se agrega a la tablas “hijas”*/


/*Ejercicio 2*/
CREATE TYPE tipo_paciente_os AS (
id INTEGER,
nombre VARCHAR(100),
apellido VARCHAR(100),
sigla VARCHAR(15),
obra_social VARCHAR(100) );

CREATE TYPE tipo_empleado AS (
id INTEGER,
nombre VARCHAR(100),
apellido VARCHAR(100),
fecha_ingreso DATE,
cargo VARCHAR(50),
especialidad VARCHAR(50) );

CREATE TYPE tipo_medicamento AS (
id INTEGER,
nombre VARCHAR(50),
stock INTEGER,
clasificacion VARCHAR(75),
laboratorio VARCHAR(50) );

CREATE TYPE tipo_consulta AS (
nombre_paciente VARCHAR(70),
apellido_paciente VARCHAR(30),
nombre_empleado VARCHAR(70),
apellido_empleado VARCHAR(30),
fecha DATE,
consultorio VARCHAR(50) );


CREATE TYPE tipo_estudio_realizado AS (
nombre_paciente VARCHAR(100),
apellido_paciente VARCHAR(100),
nombre_empleado VARCHAR(100),
apellido_empleado VARCHAR(100),
estudio VARCHAR(100),
precio NUMERIC(10,2),
fecha DATE );

CREATE TYPE tipo_internacion AS (
nombre_paciente VARCHAR(70),
apellido_paciente VARCHAR(30),
nombre_empleado VARCHAR(70),
apellido_empleado VARCHAR(30),
costo NUMERIC(10,2),
fecha_alta DATE );

drop type tipo_internacion ;

CREATE TYPE tipo_tratamiento AS (
nombre_paciente VARCHAR(100),
apellido_paciente VARCHAR(100),
nombre_empleado VARCHAR(100),
apellido_empleado VARCHAR(100),
medicamento VARCHAR(50),
dosis VARCHAR(50),
costo NUMERIC(10,2) );

CREATE TYPE tipo_facturacion AS (
id BIGINT,
fecha DATE,
monto NUMERIC(10,2),
nombre VARCHAR(100),
apellido VARCHAR(100) );

CREATE TYPE tipo_pagos AS (
nombre VARCHAR(100),
apellido VARCHAR(100),
fecha DATE,
monto NUMERIC(10,2) );

CREATE TYPE tipo_mantenimiento_equipo AS (
nombre VARCHAR(100),
apellido VARCHAR(100),
equipo VARCHAR(100),
marca VARCHAR(50),
fecha_ingreso DATE,
estado VARCHAR(25) );

/*Creacion de una particion de una tabla:
CREATE TABLE nombre_particion_tabla (
CHECK (condicion para la particion),
CONSTRAINT pk_tabla...,
CONSTRAINT fk_tabla...
)INHERITS (tabla_que_se_particiona);
*/

