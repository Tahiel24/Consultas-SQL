/*TP08*/
/*Ejercicio 1*/
ALTER TABLE tratamiento ALTER COLUMN dosis SET DATA TYPE integer USING dosis::integer;

CREATE OR REPLACE FUNCTION modifica_saldo (id_fac BIGINT) RETURNS VOID AS $$
	UPDATE factura SET saldo = monto - (SELECT SUM(monto)FROM pago WHERE id_factura=$1 )
	RAISE NOTICE 'Monto actualizado';
$$LANGUAGE plpgsql;

/*Ejercicio 2*/
/*OBS: Se crear primero la funcion, despues el trigger*/
/*NEW no esta disponible en DELETE, OLD no esta asignado para INSERT*/
/*a) */
CREATE OR REPLACE FUNCTION modifica_stock () RETURNS TRIGGER AS $mod_stock$
BEGIN
	IF (SELECT stock FROM medicamento WHERE id_medicamento = NEW.id_medicamento) > NEW.dosis THEN
		UPDATE medicamento SET stock = stock - NEW.dosis WHERE id_medicamento = NEW.id_medicamento;
	ELSE
		RAISE EXCEPTION 'No puede solicitarse esa cantidad de dosis';
	END IF;
	RETURN NEW;
END;
$mod_stock$LANGUAGE plpgsql;

CREATE TRIGGER mod_stock
BEFORE
INSERT ON tratamiento FOR EACH ROW
EXECUTE PROCEDURE modifica_stock();

/*B) */
CREATE OR REPLACE FUNCTION add_stock_med() RETURNS TRIGGER AS $add_stock_med$
BEGIN

UPDATE medicamento SET stock = stock + NEW.cantidad WHERE id_medicamento = NEW.id_medicamento;

RETURN NEW;
END;
$add_stock_med$ LANGUAGE plpgsql;

CREATE TRIGGER add_stock_med 
AFTER INSERT ON compra FOR EACH ROW 
EXECUTE PROCEDURE add_stock_med();

/*c) */
CREATE OR REPLACE FUNCTION modifica_saldo_pagada () RETURNS TRIGGER AS $saldo_pag$
DECLARE
total_pagado NUMERIC;
nuevo_saldo NUMERIC;
BEGIN
	total_pagado:= (SELECT SUM(monto)FROM pago WHERE id_factura=NEW.id_factura);
	IF (total_pagado)+NEW.monto > (SELECT monto FROM factura WHERE id_factura=NEW.id_factura)THEN
		RAISE EXCEPTION 'No puede abonarse mas de lo que se adeuda';
	ELSE
		IF nuevo_saldo > 0 THEN
			UPDATE factura SET saldo=monto - (total_pagado+NEW.monto), pagada='N' WHERE id_factura=NEW.id_factura;
		ELSE
			UPDATE factura SET saldo=monto - (total_pagado+NEW.monto), pagada='S' WHERE id_factura=NEW.id_factura;
		END IF;
		RAISE NOTICE 'Las columnas fueron actualizadas correctamente';
	END IF;
	RETURN NEW;
END;
$saldo_pag$LANGUAGE plpgsql;

CREATE TRIGGER saldo_pag 
BEFORE INSERT ON pago FOR EACH ROW
EXECUTE PROCEDURE modifica_saldo_pagada();
drop trigger saldo_pag ON pago;

/*Transaccion para probar el trigger*/
BEGIN TRANSACTION;
	INSERT INTO pago VALUES (939590, '2021-06-10', 133.00);
	select * from factura where id_factura=939590;
ROLLBACK;

/*d) */
CREATE OR REPLACE FUNCTION actualiza_al_borrar_pago () RETURNS TRIGGER AS $actualiza_borrar$
BEGIN
	UPDATE factura SET saldo = saldo + (OLD.monto), pagada='N' WHERE id_factura=OLD.id_factura;
	RAISE NOTICE 'Deuda actualizada';
	RETURN OLD;
END;
$actualiza_borrar$LANGUAGE plpgsql;

CREATE TRIGGER actualiza_borrar
BEFORE DELETE ON pago FOR EACH ROW
EXECUTE PROCEDURE actualiza_al_borrar_pago();

/*Transaccion para probar el trigger*/
BEGIN TRANSACTION;
	DELETE FROM pago WHERE id_factura=939590 AND fecha='2021-06-04';
	SELECT * FROM factura WHERE id_factura=939590;
ROLLBACK;

/*e) */
CREATE TABLE IF NOT EXISTS medicamento_reponer (
	id_medicamento INTEGER,
	nombre VARCHAR(50),
	presentacion VARCHAR(50),
	stock INTEGER,
	ult_precio NUMERIC(8,2),
	proveedor varchar(50)
);


CREATE OR REPLACE FUNCTION reponer_medicamentos () RETURNS TRIGGER AS $alta_med_reponer$
BEGIN

	IF EXISTS (SELECT * FROM medicamento_reponer WHERE id_medicamento = NEW.id_medicamento) THEN
		UPDATE medicamento_reponer SET stock=NEW.stock WHERE id_medicamento=NEW.id_medicamento;
		RAISE NOTICE 'Campo de la tabla medicamento_reponer actualizado con exito';
	ELSE
		INSERT INTO medicamento_reponer VALUES (NEW.id_medicamento, NEW.nombre, NEW.presentacion, NEW.stock, 
												(SELECT precio_unitario FROM compra WHERE id_medicamento=NEW.id_medicamento ORDER BY fecha DESC LIMIT 1),
												(SELECT proveedor FROM compra INNER JOIN proveedor USING (id_proveedor) WHERE id_medicamento=NEW.id_medicamento ORDER BY fecha DESC LIMIT 1));
		RAISE NOTICE 'Stock bajo, revisar la tabla medicamento_reponer';
	END IF;
	RETURN NEW;
END;
$alta_med_reponer$LANGUAGE plpgsql;

CREATE TRIGGER alta_med_reponer
AFTER UPDATE ON medicamento FOR EACH ROW
WHEN (NEW.stock < 50)
EXECUTE PROCEDURE reponer_medicamentos ();

DROP TRIGGER alta_med_reponer ON medicamento;

BEGIN TRANSACTION;
	UPDATE medicamento SET stock = 45 WHERE id_medicamento=2;
	select * from medicamento_reponer;
ROLLBACK;

/*f) */

CREATE OR REPLACE FUNCTION modifica_stock_por_valMayor() RETURNS TRIGGER AS $mod_al_mayor$
BEGIN
	IF EXISTS (SELECT * FROM medicamento_reponer WHERE id_medicamento=NEW.id_medicamento) AND NEW.stock + () > 50 THEN
		DELETE FROM medicamento_reponer WHERE id_medicamento=NEW.id_medicamento;
		RAISE 'Stock normal para el medicamento %', NEW.nombre;
	ELSE
		UPDATE medicamento_reponer SET stock = NEW.stock WHERE id_medicamento=NEW.id_medicamento;
		RAISE NOTICE 'Campo stock actualizado del medicamento %', NEW.nombre;
	END IF;
RETURN NEW;
END;
$mod_al_mayor$LANGUAGE;

/*Ejercicio 3*/
/*OBS: USER es la variable que contiene al usuario actual*/
/*a) */
CREATE OR REPLACE FUNCTION auditar_tabla_medicamentos () RETURNS TRIGGER AS $auditar_medicamentos$
BEGIN
CREATE TABLE IF NOT EXISTS audita_medicamento (
	id serial,
	usuario VARCHAR,
	fecha TIMESTAMP,
	operacion CHAR(1),
	estado VARCHAR,
	id_medicamento integer,
	id_clasificacion smallint,
	id_laboratorio smallint, 
	nombre varchar(50),
	presentacion varchar(50),
	precio NUMERIC(8,2),
	stock integer
);

CASE
	WHEN TG_OP='INSERT' THEN
		INSERT INTO audita_medicamento VALUES (default, USER, NOW(), 'I', 'alta', NEW.id_medicamento, NEW.id_clasificacion, NEW.id_laboratorio, NEW.nombre, NEW.presentacion, NEW.precio, NEW.stock);
	WHEN TG_OP='DELETE' THEN
		INSERT INTO audita_medicamento VALUES (default, USER, NOW(), 'D', 'baja', NEW.id_medicamento, NEW.id_clasificacion, NEW.id_laboratorio, NEW.nombre, NEW.presentacion, NEW.precio, NEW.stock);
	WHEN TG_OP='UPDATE' THEN
		INSERT INTO audita_medicamento VALUES (default, USER, NOW(), 'U', 'antes', OLD.id_medicamento, OLD.id_clasificacion, OLD.id_laboratorio, OLD.nombre, OLD.presentacion, OLD.precio, OLD.stock);
		INSERT INTO audita_medicamento VALUES (default, USER, NOW(), 'U', 'despues', NEW.id_medicamento, NEW.id_clasificacion, NEW.id_laboratorio, NEW.nombre, NEW.presentacion, NEW.precio, NEW.stock);
END CASE;

RETURN NEW;

END;
$auditar_medicamentos$LANGUAGE plpgsql;

CREATE TRIGGER auditar_medicamentos
AFTER INSERT OR UPDATE OR DELETE ON medicamento FOR EACH ROW
EXECUTE PROCEDURE auditar_tabla_medicamentos();

BEGIN TRANSACTION;
	update medicamento set stock= 40 where id_medicamento=1;
	select * from audita_medicamento;
ROLLBACK;

/*b) */
CREATE OR REPLACE FUNCTION auditar_empleados () RETURNS TRIGGER AS $auditando_empleados$
DECLARE 
diferencia numeric;
BEGIN
CREATE TABLE IF NOT EXISTS audita_empleado_sueldo (
	id serial,
	usuario VARCHAR,
	fecha TIMESTAMP,
	id_empleado INTEGER,
	nombre VARCHAR(70),
	apellido VARCHAR(30),
	sueldo_v NUMERIC(9,2),
	sueldo_n NUMERIC(9,2),
	diferencia NUMERIC (9,2),
	estado VARCHAR
);
	diferencia:=(NEW.sueldo-OLD.sueldo);
	IF NEW.sueldo > OLD.sueldo THEN
		INSERT INTO audita_empleado_sueldo VALUES (default, USER, NOW(), NEW.id_empleado, (SELECT nombre FROM persona WHERE id_persona=NEW.id_empleado), 
												   (SELECT apellido FROM persona WHERE id_persona=NEW.id_empleado), OLD.sueldo, NEW.sueldo, diferencia, 'aumento');
	ELSE
		INSERT INTO audita_empleado_sueldo VALUES (default, USER, NOW(), NEW.id_empleado, (SELECT nombre FROM persona WHERE id_persona=NEW.id_empleado), 
												   (SELECT apellido FROM persona WHERE id_persona=NEW.id_empleado), OLD.sueldo, NEW.sueldo, diferencia, 'descuento');
	END IF;
	RETURN NEW;
END;
$auditando_empleados$LANGUAGE plpgsql;

CREATE TRIGGER auditando_empleados
AFTER UPDATE ON empleado FOR EACH ROW
WHEN (NEW.sueldo <> OLD.sueldo)
EXECUTE PROCEDURE auditar_empleados();

BEGIN TRANSACTION;
	UPDATE empleado SET sueldo=144000.00 WHERE id_empleado=1;
	select * from audita_empleado_sueldo;
	UPDATE empleado SET sueldo=143000.00 WHERE id_empleado=1;
	select * from audita_empleado_sueldo;
	UPDATE empleado SET fecha_ingreso='2014-01-27' WHERE id_empleado=1;
	select * from audita_empleado_sueldo;
ROLLBACK;



