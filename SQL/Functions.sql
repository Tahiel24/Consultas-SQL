/*OBSERVACION IMPORTANTE: AL HACER CONSULTAS DINAMICAS SE UTILIZAN ''' (tres comillas simples para formatear datos de tipo fecha en un formato adecuado), CASO CONTRARIO usar comillas simples*/
/*TP07*/
/*Ejercicio 1*/
/*a)*/
CREATE FUNCTION modifica_fecha(p_dni VARCHAR, c_name VARCHAR, valor DATE) RETURNS VOID AS $$
DECLARE
query TEXT;
id_emp INTEGER;
BEGIN
	IF NOT EXISTS (SELECT * FROM persona WHERE dni=$1)THEN
		RAISE EXCEPTION 'La persona con el dni ingresado no existe';
	END IF;
	IF c_name!='fecha_ingreso' AND c_name!='fecha_baja' THEN
		RAISE EXCEPTION 'Ingrese un campo de fecha valido a modificar';
	END IF;
	id_emp:= (SELECT id_empleado FROM persona INNER JOIN empleado ON id_persona=id_empleado WHERE dni=$1);
	IF $2 = 'fecha_baja' AND $3 < (SELECT fecha_ingreso
												FROM empleado
												WHERE id_empleado = id_emp) THEN
		RAISE EXCEPTION 'La fecha de baja no puede ser anterior a la fecha de ingreso.';
	END IF;
	query:= 'UPDATE empleado SET '||$2||'='''||$3||''' WHERE id_empleado='||id_emp;
	EXECUTE query;
	RAISE NOTICE 'Empleado modificado exitosamente';
END;
$$LANGUAGE plpgsql;

DROP FUNCTION modifica_fecha;

SELECT modifica_fecha('37870755','fecha_baja','2013-08-10');

/*b)*/
/*OBS: No era necesaria la consulta dinamica, se podia hacer una normal en todos los apartados del case*/
CREATE FUNCTION modifica_precio (op CHAR, nom VARCHAR, aum_desc CHAR, porc NUMERIC) RETURNS VOID AS $$
DECLARE
query TEXT;
id_req integer;
BEGIN
	IF $1!='L' AND $1!='P' AND $1!='M' THEN
		RAISE EXCEPTION 'Modificacion ingresada invalida';
	END IF;
	IF $2 IS NULL OR $2='' THEN
		RAISE EXCEPTION 'El segundo campo no puede estar vacio';
	END IF;
	IF $3!='A' AND $3!='D' THEN
		RAISE EXCEPTION 'Debe ingresar si es aumento o descuento';
	END IF;
	IF $4 < 0 OR $4 > 0.99 THEN
		RAISE EXCEPTION 'Ingrese un porcentaje valido';
	END IF;
	CASE op
		WHEN op='L' THEN
			IF NOT EXISTS (SELECT * FROM laboratorio WHERE laboratorio=$2)THEN
				RAISE EXCEPTION 'Ingrese un nombre de laboratorio valido';
			END IF;
			id_req:= (SELECT id_laboratorio FROM laboratorio WHERE laboratorio=nom);
			IF aum_desc='A' THEN
				query:='UPDATE medicamento SET precio=precio+((precio*'||porc||')/100) WHERE id_laboratorio='||id_req;
				EXECUTE query;
				RAISE NOTICE 'Medicamento con el laboratorio % actualizados con exito', nom;
			ELSE
				query:='UPDATE medicamento SET precio=precio-((precio*'||porc||')/100) WHERE id_laboratorio='||id_req;
				EXECUTE query;
				RAISE NOTICE 'Medicamento con el laboratorio % actualizados con exito', nom;
			END IF;
		WHEN op='P' THEN
			IF NOT EXISTS (SELECT * FROM proveedor WHERE proveedor=$2)THEN
				RAISE EXCEPTION 'Ingrese un nombre de proveedor valido';
			END IF;
			id_req:= (SELECT id_proveedor FROM proveedor WHERE proveedor=nom);
			IF aum_desc='A' THEN
				query:='UPDATE medicamento SET precio=precio+((precio*'||porc||')/100) WHERE id_proveedor='||id_req;
				EXECUTE query;
				RAISE NOTICE 'Medicamento con el proveedor % actualizados con exito', nom;
			ELSE
				query:='UPDATE medicamento SET precio=precio-((precio*'||porc||')/100) WHERE id_proveedor='||id_req;
				EXECUTE query;
				RAISE NOTICE 'Medicamento con el proveedor % actualizados con exito', nom;
			END IF;
		WHEN op='M' THEN
			IF NOT EXISTS (SELECT * FROM laboratorio WHERE laboratorio=$2)THEN
				RAISE EXCEPTION 'Ingrese un nombre de medicamento valido';
			END IF;
			id_req:= (SELECT id_medicamento FROM medicamento WHERE nombre=nom);
			IF aum_desc='A' THEN
				query:='UPDATE medicamento SET precio=precio+((precio*'||porc||')/100) WHERE id_medicamento='||id_req;
				EXECUTE query;
				RAISE NOTICE 'Medicamento con el laboratorio % actualizados con exito', nom;
			ELSE
				query:='UPDATE medicamento SET precio=precio-((precio*'||porc||')/100) WHERE id_medicamento='||id_req;
				EXECUTE query;
				RAISE NOTICE 'Medicamento con el nombre % actualizados con exito', nom;
			END IF;
	END CASE;
END;
$$LANGUAGE plpgsql;

/*d) */
CREATE FUNCTION alta_tabla (nom_tabla VARCHAR, valor VARCHAR) RETURNS VOID AS $$
BEGIN
	IF $1 IS NULL OR $1='' THEN
		RAISE NOTICE 'Se debe enviar el nombre de la tabla';
	END IF;
	IF $2 IS NULL OR $2='' THEN
		RAISE NOTICE 'No puede estar vacio el valor a agregar';
	END IF;
	CASE nom_tabla
		WHEN nom_tabla='tipo_estudio' THEN
			INSERT INTO tipo_estudio VALUES ((SELECT MAX(id_tipo)+1 FROM tipo_estudio), valor);
			RAISE NOTICE 'Valor agregado en la tabla tipo_estudio';
		WHEN nom_tabla='patologia' THEN
			INSERT INTO patologia VALUES ((SELECT MAX(id_patologia)+1 FROM patologia), valor);
			RAISE NOTICE 'Valor agregado en la tabla patologia';
		WHEN nom_tabla='clasificacion' THEN
			INSERT INTO clasificacion VALUES ((SELECT MAX(id_clasificacion)+1 FROM clasificacion), valor);
			RAISE NOTICE 'Valor agregado en la tabla clasificacion';
		WHEN nom_tabla='especialidad' THEN
			INSERT INTO especialidad VALUES ((SELECT MAX(id_especialidad)+1 FROM especialidad), valor);
			RAISE NOTICE 'Valor agregado en la tabla tipo_estudio';
		ELSE
			RAISE EXCEPTION 'El nombre de la tabla ingresado no es correcto';
	END CASE;
END;
$$LANGUAGE plpgsql;

/*Ejercicio 2*/
/*OBS: Verificar que los campos de los UDT coincidan en tipo y numero de caracteres que los de la tabla, caso contrario dara error al querer trabajar con ellos*/
/*a) */
CREATE OR REPLACE FUNCTION listar_pacientes_con_os (nom_os VARCHAR) RETURNS SETOF tipo_paciente_os AS $$
DECLARE 
row_pac tipo_paciente_os;
BEGIN
	FOR row_pac IN SELECT id_persona, p.nombre, apellido, sigla, os.nombre FROM persona p
					INNER JOIN paciente ON id_persona=id_paciente
					INNER JOIN obra_social os USING (id_obra_social)
					WHERE os.nombre=$1
	LOOP
		RETURN NEXT row_pac;
	END LOOP;
	RETURN;
END;
$$LANGUAGE plpgsql; 

SELECT listar_pacientes_con_os('OBRA SOCIAL PORTUARIOS ARGENTINOS DE MAR DEL PLATA');

/*b) */
CREATE TYPE tipo_medicamento_n AS(
	id_med integer,
	nombre_med varchar(50),
	clasificacion varchar, 
	nombre_lab varchar(75),
	nom_proveedor varchar(50),
	precio numeric(8,2)
);

CREATE OR REPLACE FUNCTION listar_medicamentos_por_proveedor (nom_prov VARCHAR) RETURNS SETOF tipo_medicamento_n AS $$
DECLARE
	fila_med tipo_medicamento_n;
BEGIN
	FOR fila_med IN SELECT id_medicamento, nombre, clasificacion, laboratorio, proveedor, precio_unitario FROM medicamento
						INNER JOIN laboratorio USING (id_laboratorio)
						INNER JOIN clasificacion USING (id_clasificacion)
						INNER JOIN compra USING (id_medicamento)
						INNER JOIN proveedor USING (id_proveedor)
						WHERE proveedor=$1
		LOOP
			RETURN NEXT fila_med;
		END LOOP;
	RETURN;
END;
$$LANGUAGE plpgsql;

SELECT listar_medicamentos_por_proveedor ('QUIMICA SUIZA S.A.');

/*c) */
CREATE OR REPLACE FUNCTION consultas_por_fecha (fec DATE) RETURNS SETOF tipo_consulta AS $$
BEGIN
	RETURN QUERY SELECT pac.nombre, pac.apellido, emp.nombre, emp.apellido, fecha, con.nombre FROM consulta c
					INNER JOIN persona pac ON c.id_paciente=pac.id_persona
					INNER JOIN persona emp ON c.id_empleado=emp.id_persona
					INNER JOIN consultorio con USING (id_consultorio)
					WHERE fecha=$1;
END;
$$LANGUAGE plpgsql;


/*d) */
CREATE OR REPLACE FUNCTION internaciones_por_dni (p_dni varchar) RETURNS SETOF tipo_internacion AS $$
BEGIN
	RETURN QUERY SELECT  pac.nombre, pac.apellido, emp.nombre, emp.apellido, costo, fecha_alta FROM internacion i
					INNER JOIN persona pac ON i.id_paciente=pac.id_persona
					INNER JOIN persona emp ON i.ordena_internacion=emp.id_persona
					WHERE pac.dni=p_dni AND fecha_alta IS NOT NULL;
END;	
$$LANGUAGE plpgsql;

SELECT internaciones_por_dni ('68858698');

/*h) */
CREATE TYPE tipo_facturacion_deuda AS (
	id BIGINT,
	fecha DATE,
	monto NUMERIC(10,2),
	nombre VARCHAR(70),
	apellido VARCHAR(30),
	deuda TEXT
);

CREATE OR REPLACE FUNCTION listar_facturas () RETURNS SETOF tipo_facturacion_deuda AS $$
BEGIN
	RETURN QUERY SELECT id_factura, fecha, monto, nombre, apellido, CASE 
																		WHEN saldo < 500000 THEN 'El cobro puede esperar'
																		WHEN saldo > 500000 THEN 'Cobrar prioridad'
																		WHEN saldo > 1000000 THEN 'Cobrar urgente'
																	END AS deuda
					FROM factura
					INNER JOIN persona ON id_persona=id_factura;
END;				
$$LANGUAGE plpgsql;


SELECT listar_facturas ();

/*i) */
CREATE TYPE valores_tabla AS (
	id SMALLINT,
	valor VARCHAR
);

CREATE OR REPLACE FUNCTION listar_registros (nom_tabla VARCHAR) RETURNS SETOF valores_tabla AS $$
BEGIN
	IF $1 IS NULL OR ($1!='cargo' AND $1!='especialidad' AND $1!='clasificacion' AND $1!='patologia' AND $1!='tipo_estudio')THEN
		RAISE EXCEPTION 'Ingrese un nombre valido para la tabla';
	END IF;
	RETURN QUERY EXECUTE 'SELECT * FROM '||nom_tabla;
END;
$$LANGUAGE plpgsql;

select listar_registros ('cargo');

/*Ejercicio 4*/
/*a) */
CREATE OR REPLACE FUNCTION despachar_cama (m_id_cama INTEGER,fecha_eg DATE, dni_emp VARCHAR, c_estado VARCHAR) RETURNS VOID AS $$
DECLARE
id_emp INTEGER;
BEGIN
	IF dni_emp IS NULL OR NOT EXISTS (SELECT * FROM persona INNER JOIN empleado ON id_persona=id_empleado WHERE dni=dni_emp)THEN
		RAISE EXCEPTION 'El empleado con el DNI ingresado no existe';
	END IF;
	IF NOT EXISTS (SELECT * FROM cama WHERE id_cama=$1)THEN
		RAISE EXCEPTION 'Ingrese una cama valida que este en mantenimiento';
	END IF;
	IF NOT EXISTS (SELECT * FROM mantenimiento_cama WHERE id_cama=$1 AND fecha_egreso IS NULL)THEN
		RAISE EXCEPTION 'La cama ingresada no esta en mantenimiento';
	END IF;		
	IF fecha_eg < (SELECT fecha_ingreso FROM mantenimiento_cama WHERE id_cama=$1 AND fecha_egreso IS NULL)THEN
		RAISE EXCEPTION 'La fecha de egreso ingresada no puede ser menor a la fecha de ingreso';	
	END IF;
	IF c_estado IS NULL OR c_estado='' THEN 
		RAISE EXCEPTION 'El campo estado no puede ser nulo o vacio';
	END IF;
	IF c_estado!='reparado' AND c_estado!='Fuera de Servicio' THEN
		RAISE EXCEPTION 'Ingrese un estado valido(reparado/Fuera de Servicio)';
	END IF;
	
	id_emp:= (SELECT id_persona FROM persona WHERE dni=dni_emp);
	
	UPDATE mantenimiento_cama SET estado=$4, fecha_egreso=$2, demora=(fecha_eg - fecha_ingreso), id_empleado=id_emp
		WHERE id_cama=$1 AND fecha_egreso IS NULL;
		
	IF $4='reparado'THEN
		UPDATE cama SET estado='OK' WHERE id_cama=$1;
	ELSE
		UPDATE cama SET estado='FUERA DE SERVICIO' WHERE id_cama=$1;
	END IF;
END;
$$LANGUAGE plpgsql;

BEGIN TRANSACTION;
	SELECT despachar_cama (129, '2023-03-01', '17243472', 'Fuera de Servicio');
	SELECT * FROM mantenimiento_cama WHERE id_cama=129 AND fecha_egreso='2023-03-01';
	select * from cama where id_cama=129;
ROLLBACK;

/*b) */
select * from internacion;

CREATE OR REPLACE FUNCTION alta_paciente(p_fecha_alta DATE, p_hora time without time zone, p_costo numeric(10,2), dni_pac VARCHAR) RETURNS BOOLEAN AS $$
DECLARE
id_pac INTEGER;
BEGIN
	IF $4 IS NULL OR NOT EXISTS (SELECT * FROM persona INNER JOIN paciente ON id_persona=id_paciente WHERE dni=$4)THEN
		RAISE EXCEPTION 'Ingrese un paciente valido a ser evaluado';
	END IF;
	
	id_pac:=(SELECT id_persona FROM persona WHERE dni=$4);
	
	IF $1 < (SELECT fecha_inicio FROM internacion WHERE id_paciente=id_pac AND fecha_alta IS NULL) THEN
		RAISE EXCEPTION 'La fecha de alta no puede ser menor a la fecha de inicio de internacion';
	END IF;
	
	IF p_hora IS NULL THEN
		RAISE EXCEPTION 'Ingrese un valor valido en el campo hora';
	END IF;
	
	IF p_costo < 1 OR p_costo IS NULL THEN
		RAISE EXCEPTION 'Ingrese un costo de internacion valido';
	END IF;
	
	UPDATE internacion SET fecha_alta=$1, hora=$2, costo=$3 WHERE id_paciente=id_pac AND fecha_alta IS NULL;
	
	RETURN true;
END;
$$LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ingresa_factura (dni_pac VARCHAR, fec DATE, hora_emision TIME WITHOUT TIME ZONE, f_monto NUMERIC(10,2)) RETURNS BOOLEAN AS $$
DECLARE 
id_pac INTEGER;
BEGIN
	IF $1 IS NULL OR NOT EXISTS (SELECT * FROM persona INNER JOIN paciente ON id_persona=id_paciente WHERE dni=$1)THEN
		RAISE EXCEPTION 'Ingrese un paciente valido a ser facturado';
	END IF;
	
	id_pac:=(SELECT id_persona FROM persona WHERE dni=$1);
	
	IF $2 IS NULL THEN
		RAISE EXCEPTION 'Ingrese una fecha de facturacion valida';
	END IF;
	
	IF $4 IS NULL OR $4 < 1 THEN
		RAISE EXCEPTION 'Ingrese un monto valido de facturacion';
	END IF;
	
	INSERT INTO factura VALUES ((SELECT MAX(id_factura)+1 FROM factura), id_pac, fec, hora_emision, f_monto, 'N', f_monto);
	
	RETURN true;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE internacion_factura_alta (p_dni VARCHAR, p_fecha_alta DATE, p_hora TIME WITHOUT TIME ZONE, internacion_costo NUMERIC(10,2)) AS $$
DECLARE
	b_alta_internacion boolean;
	b_alta_factura boolean;
BEGIN
	b_alta_internacion:= (SELECT alta_paciente($2, $3, $4, $1));
	IF b_alta_internacion THEN
		b_alta_factura:= (SELECT ingresa_factura($1, $2, $3, $4));
		IF b_alta_factura THEN
			RAISE NOTICE 'Alta de la internacion y factura generadas con exito para el paciente con el DNI: %', $1;
		ELSE
			RAISE EXCEPTION 'Error en la generacion de la factura: %', SQLERRM;
		END IF;
	ELSE
		RAISE EXCEPTION 'Error en la insercion del paciente: %', SQLERRM;
	END IF;
END;
$$LANGUAGE plpgsql;


BEGIN TRANSACTION;
INSERT INTO internacion VALUES (26909, 24, '2023-01-04', 112);
CALL internacion_factura_alta('45705891', '2023-02-20','17:05:01', '320000.00');
select * from internacion where id_paciente=26909 AND fecha_alta='2023-02-20';
select * from factura where fecha='2023-02-20' AND hora='17:05:01' AND monto=320000.00;
ROLLBACK;





















