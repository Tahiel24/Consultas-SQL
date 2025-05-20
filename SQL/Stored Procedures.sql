/*Ejercicio 1*/
/*a) */
CREATE PROCEDURE sp_alta_persona (nom VARCHAR(70), ape VARCHAR(30), dni VARCHAR(8), fecha_nac DATE, domicilio varchar(100), telefono varchar(15)) AS $$
DECLARE
	p_id INTEGER;
BEGIN
	IF nom IS NULL OR nom='' THEN
		RAISE EXCEPTION 'El nombre es obligatorio';
	END IF;
	IF ape IS NULL OR ape='' THEN
		RAISE EXCEPTION 'El apellido es obligatorio';
	END IF;
	IF dni IS NULL OR dni='' THEN
		RAISE EXCEPTION 'El DNI es obligatorio';
	END IF;
	IF EXISTS (SELECT * FROM persona p WHERE p.dni=$3) THEN
		RAISE EXCEPTION 'La persona con el DNI ingresado ya existe';
	END IF;
	
	SELECT MAX(id_persona)+1 INTO p_id FROM persona;
	
	INSERT INTO persona 
		VALUES (p_id, nom, ape, dni, fecha_nac, domicilio, telefono);
	RAISE NOTICE 'Persona con el dni % insertada con exito', dni;
	
	EXCEPTION
		WHEN OTHERS THEN
		RAISE EXCEPTION 'Error en la inserción de persona: %', SQLERRM;
END;
$$LANGUAGE plpgsql;

CALL sp_alta_persona ('Luis','Jimenez','43675899','2000-02-21','Avenida Las Heras 654-San Miguel de Tucumán-Tucumán','3814565899');

/*b) */
CREATE PROCEDURE sp_alta_empleado (e_dni varchar(8), esp VARCHAR(100),e_cargo VARCHAR(100), fecha_ing DATE, e_sueldo NUMERIC(9,2), e_fecha_baja DATE) AS $$
DECLARE
id_emp INTEGER;
id_esp SMALLINT;
id_car SMALLINT;
BEGIN
	IF NOT EXISTS (SELECT * FROM persona WHERE dni=$1) THEN
		RAISE EXCEPTION 'Ingrese un DNI registrado en el sistema';
	END IF;
	IF NOT EXISTS (SELECT * FROM especialidad WHERE especialidad=$2)THEN
		RAISE EXCEPTION 'No existe la especialidad ingresada';
	END IF;
	IF NOT EXISTS (SELECT * FROM cargo WHERE cargo=$3)THEN
		RAISE EXCEPTION 'No existe el cargo ingresado';
	END IF;
	
	id_emp:= (SELECT id_persona FROM persona WHERE dni=$1);
	id_esp:= (SELECT id_especialidad FROM especialidad WHERE especialidad=$2);
	id_car:= (SELECT id_cargo FROM cargo WHERE cargo=$3);
	
	INSERT INTO empleado VALUES (id_emp, id_esp, id_car, $4, $5, $6);
	RAISE NOTICE 'Empleado con el dni % insertado con exito', $1;
	
	EXCEPTION
		WHEN OTHERS THEN
		RAISE EXCEPTION 'Error en la inserción del empleado: %', SQLERRM;
END;
$$LANGUAGE plpgsql

DROP PROCEDURE sp_alta_empleado;

CALL sp_alta_empleado('6210511','CARDIOLOGÍA','GERENTE','2022-12-10',90000.00,NULL);

/*c) */
CREATE PROCEDURE sp_factura_modifica_saldo (id_fac BIGINT, monto_pag NUMERIC(10,2)) AS $$
DECLARE

BEGIN
	IF NOT EXISTS(SELECT * FROM factura WHERE id_factura=$1)THEN
		RAISE EXCEPTION 'El numero de factura ingresado no existe';
	END IF;
	IF monto_pag IS NULL OR monto_pag < 0 THEN
		RAISE EXCEPTION 'Se debe ingresar un monto positivo como pago';
	END IF;
	IF monto_pag > (SELECT saldo FROM factura WHERE id_factura=$1) THEN
		RAISE EXCEPTION 'No se puede realizar un pago mayor a lo que adeuda';
	END IF;
	UPDATE factura SET saldo=saldo-$2 WHERE id_factura=$1;
	RAISE NOTICE 'Monto de factura actualizado con exito';
	
	EXCEPTION
		WHEN OTHERS THEN
		RAISE EXCEPTION 'Error en la actualizacion del monto de la factura: %', SQLERRM;
END;
$$LANGUAGE plpgsql;

/*D) */
/*Escriba un SP para modificar el precio de la tabla medicamento. La función 
debe recibir por parámetro, el nombre de un laboratorio y el porcentaje de 
aumento. Verifique que el laboratorio exista y modifique todos
los medicamentos de ese laboratorio. 
Nombre sugerido: medicamento_modifica_por_laboratorio.*/

CREATE PROCEDURE sp_medicamento_modifica_por_laboratorio (nom_lab VARCHAR, porc_aum NUMERIC) AS $$
BEGIN
	IF porc_aum < 0 OR porc_aum > 99.99 THEN
		RAISE EXCEPTION 'El porcentaje ingresado no es correcto';
	END IF;
	IF nom_lab IS NULL OR nom_lab='' THEN
		RAISE EXCEPTION 'El campo laboratorio no puede estar vacio';
	END IF;
	IF NOT EXISTS (SELECT * FROM laboratorio WHERE laboratorio=$1)THEN
		RAISE EXCEPTION 'No existe el laboratorio ingresado';
	END IF;
	UPDATE medicamento SET precio = precio + ((precio*$2)/100) WHERE id_laboratorio=(SELECT id_laboratorio FROM laboratorio WHERE laboratorio=$1);
	EXCEPTION
		WHEN OTHERS THEN
		RAISE EXCEPTION 'Error en la actualizacion de los medicamentos: %', SQLERRM;
END;
$$LANGUAGE plpgsql;

/*Ejercicio 2*/
/*a) */
CREATE PROCEDURE sp_paciente_obtener (p_dni varchar, OUT nom_pac varchar, OUT ape_pac varchar) AS $$
	BEGIN
		SELECT nombre, apellido INTO nom_pac, ape_pac FROM persona WHERE dni=$1;
		EXCEPTION
			WHEN OTHERS THEN 
			RAISE EXCEPTION 'No se pudo realizar la accion: %', SQLERRM;
	END;
$$LANGUAGE plpgsql;

drop procedure sp_obra_social_listado;

/*Con el bloque DO y declarando variables puedo atrapar los valores de salida del SP*/
DO $$
DECLARE
    nom_pac varchar;
    ape_pac varchar;
BEGIN
    CALL sp_paciente_obtener('18354930', nom_pac, ape_pac);
    RAISE NOTICE 'Nombre: %, Apellido: %', nom_pac, ape_pac;
END;
$$;

/*b)*/
CREATE PROCEDURE sp_medicamento_precio_stock (nom_med VARCHAR, OUT prec NUMERIC, OUT stK INTEGER) AS $$
BEGIN
	IF NOT EXISTS (SELECT * FROM medicamento WHERE nombre=$1)THEN
		RAISE EXCEPTION 'El medicamento ingresado no existe';
	END IF;
	SELECT precio, stock INTO $2, $3 FROM medicamento WHERE nombre=$1;
END;
$$LANGUAGE plpgsql;


DO $$
DECLARE
prec NUMERIC;
stk INTEGER;
BEGIN
	CALL sp_medicamento_precio_stock('PANADOL MASTICABLE NINOS',prec,stk);
	RAISE NOTICE 'Precio del medicamento: %. Stock: %', prec, stk;
END;
$$

/*c) */
CREATE PROCEDURE sp_deuda_paciente (p_dni VARCHAR, OUT total_adeudado NUMERIC) AS $$
DECLARE
id_pac INTEGER;
BEGIN
	IF NOT EXISTS (SELECT * FROM persona WHERE dni=$1)THEN
		RAISE EXCEPTION 'No existe el paciente con el DNI ingresado';
	END IF;
	id_pac:=(SELECT id_persona FROM persona WHERE dni=$1);
	SELECT SUM(saldo) INTO total_adeudado FROM factura
		WHERE id_paciente=id_pac;
END;
$$LANGUAGE plpgsql;

DROP PROCEDURE sp_deuda_paciente;

DO $$
DECLARE
total NUMERIC;
BEGIN
	CALL sp_deuda_paciente('68858698', total);
	RAISE NOTICE 'Total adeudado: %', total;
END;
$$

/*d) */
CREATE PROCEDURE cama_cantidad_mantenimiento (id_c INTEGER, OUT total_veces INTEGER) AS $$
BEGIN
	/*Inserte control de si existe el id cama o no*/
	SELECT COUNT(id_cama) INTO total_veces FROM mantenimiento_cama 
	WHERE id_cama=$1
	GROUP BY id_cama;
END;
$$LANGUAGE plpgsql;

DO $$
DECLARE
total integer;
BEGIN
	CALL cama_cantidad_mantenimiento(47, total);
	RAISE NOTICE 'Total de veces que estuvo en mantenimiento: %', total;
END;
$$

/*Ejercicio 3*/
/*a) */
CREATE PROCEDURE obra_social_listado () AS $$
DECLARE
	cursor_os CURSOR FOR SELECT * FROM obra_social;
	os_row obra_social%ROWTYPE;
BEGIN
	OPEN cursor_os;
	LOOP
		FETCH cursor_os INTO os_row;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE 'ID: %, Sigla: %, Nombre: %, Dirección: %, Localidad: %, Provincia: %, Teléfono: %', os_row.id_obra_social, os_row.sigla, os_row.nombre, os_row.direccion, os_row.localidad, os_row.provincia, os_row.telefono;
	END LOOP;
	CLOSE cursor_os;
END;
$$LANGUAGE plpgsql;

CALL obra_social_listado ();

/*b) */
CREATE PROCEDURE cama_listado_ok () AS $$
DECLARE
cama_cursor CURSOR FOR SELECT * FROM cama 
						WHERE estado LIKE 'OK';
cama_row cama%ROWTYPE;
BEGIN
OPEN cama_cursor;
	LOOP
		FETCH cama_cursor INTO cama_row;
		EXIT WHEN NOT FOUND;
			RAISE NOTICE 'Id_cama: %, tipo: %, estado: %, id_habitacion: %', cama_row.id_cama, cama_row.tipo, cama_row.estado, cama_row.id_habitacion;
	END LOOP;
CLOSE cama_cursor;
END;
$$LANGUAGE plpgsql;

CALL cama_listado_ok ();


/*C) */
CREATE PROCEDURE medicamentos_poco_stock () AS $$
DECLARE
med_cursor CURSOR FOR SELECT id_medicamento, stock from medicamento
						WHERE stock < 50;
med_row medicamento%ROWTYPE;
BEGIN
OPEN med_cursor;
	LOOP
		FETCH med_cursor INTO med_row;
		EXIT WHEN NOT FOUND;
			RAISE NOTICE 'Id_med: %, stock: %', med_row.id_medicamento, med_row.stock;
	END LOOP;
CLOSE med_cursor;
END;
$$LANGUAGE plpgsql;

DROP PROCEDURE medicamentos_poco_stock;

CALL medicamentos_poco_stock ();

/*D) */
/*IDEM a los anteriores*/

/*E) */
CREATE OR REPLACE PROCEDURE estudio_por_paciente(pacDNI varchar) AS $$
	DECLARE
		estudio_cursor CURSOR FOR SELECT CONCAT(persona.nombre, ' ', apellido), fecha, estudio.nombre FROM persona
									INNER JOIN paciente ON id_persona=id_paciente
									INNER JOIN estudio_realizado USING(id_paciente)
									INNER JOIN estudio USING (id_estudio)
									WHERE dni=$1;
		nom_ape VARCHAR;
		fecEst DATE;
		nom_est VARCHAR;
	BEGIN
		OPEN estudio_cursor;
			LOOP
				FETCH estudio_cursor INTO nom_ape, fecEst, nom_est;
					EXIT WHEN NOT FOUND;
						RAISE NOTICE 'Nombre y Apellido: %, Fecha del estudio: %, Nombre del estudio: %', nom_ape, fecEst, nom_est;
			END LOOP;
		CLOSE estudio_cursor;
	END;
$$LANGUAGE plpgsql;

drop procedure estudio_por_paciente;

CALL estudio_por_paciente('6284417');

/*F)*/
CREATE OR REPLACE PROCEDURE empleado_por_turno(IN p_turno character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
cursor_turno CURSOR FOR
SELECT nombre, apellido, telefono, turno
FROM empleado
INNER JOIN persona ON id_persona = id_empleado
INNER JOIN trabajan USING(id_empleado)
INNER JOIN turno USING(id_turno)
WHERE fin IS NULL AND turno = p_turno;
v_nombre character varying(100);
v_apellido character varying(100);
v_telefono character varying(100);
v_turno character varying(25);
BEGIN
OPEN cursor_turno;
LOOP
FETCH cursor_turno INTO v_nombre, v_apellido, v_telefono, v_turno;
EXIT WHEN NOT FOUND;
RAISE NOTICE 'Nombre: %, Apellido: %, Teléfono: %, Turno: %', v_nombre, v_apellido, v_telefono, v_turno;
END LOOP;
CLOSE cursor_turno;
END; $BODY$;

/*Ejercicio 4*/
/*a)*/
CREATE PROCEDURE medicamento_laboratorio_clasificacion(nom_lab VARCHAR, nom_clas VARCHAR) AS $$
	DECLARE
		medN_cursor CURSOR FOR SELECT * FROM medicamento 
								INNER JOIN clasificacion USING (id_clasificacion)
								INNER JOIN laboratorio USING (id_laboratorio)
								WHERE laboratorio = $1 AND clasificacion = $2
									AND precio < (SELECT AVG(precio) FROM medicamento WHERE id_laboratorio IN(SELECT id_laboratorio FROM laboratorio WHERE laboratorio=$1)
												   AND id_clasificacion IN (SELECT id_clasificacion FROM clasificacion WHERE clasificacion=$2));
		fila_med medicamento%ROWTYPE;
	BEGIN
		OPEN medN_cursor;
			LOOP
				FETCH medN_cursor INTO fila_med;
				EXIT WHEN NOT FOUND;
					RAISE NOTICE 'Nombre: %, Presentacion: %, Precio: %, Stock: % ', fila_med.nombre, fila_med.presentacion, fila_med.precio, fila_med.stock;
			END LOOP;
		CLOSE medN_cursor;
	END;
$$LANGUAGE plpgsql;

DROP PROCEDURE medicamento_laboratorio_clasificacion;

CALL medicamento_laboratorio_clasificacion('FARPASA FARMACEUTICA DEL PACIFICO', 'ANALGESICOS ANTIPIRETICOS NO NARCOTICOS');





