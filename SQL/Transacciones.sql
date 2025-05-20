/*Nuevo dia, otro tp*/
/*Ejercicio 1*/
BEGIN TRANSACTION;
INSERT INTO persona (id_persona, nombre, apellido, dni, fecha_nacimiento, domicilio, telefono) VALUES ((SELECT MAX(id_persona)+1 FROM persona), 'ALEJANDRA', 'HERRERA', '37366992', '1992-06-20', 'SAN JUAN 258', '54-381-326-1780');

INSERT INTO paciente (id_paciente, id_obra_social) VALUES ((SELECT MAX(id_persona) FROM persona), 137);

INSERT INTO consulta (id_paciente, id_empleado, fecha, id_consultorio, hora, resultado) VALUES ((SELECT MAX(id_persona) FROM persona), 253, '2023-03-23', 5, '14:14:00', 'SE DIAGNOSTICA DERMATITIS');

COMMIT;

/*Ejercicio 2*/
START TRANSACTION;
UPDATE medicamento
SET precio = precio * 1.02
WHERE id_laboratorio = (SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE 'ABBOTT LABORATORIOS')
AND id_clasificacion IN (SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%');
SAVEPOINT abbott;
UPDATE medicamento
SET precio = precio * 0.965
WHERE id_laboratorio = (SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE 'BAYER QUIMICAS UNIDAS S.A.')
AND id_clasificacion IN (SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%');
SAVEPOINT bayer;
UPDATE medicamento
SET precio = precio * 1.08
WHERE id_laboratorio = (SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE 'COFANA (CONSORCIO FARMACEUTICO NACIONAL)')
AND id_clasificacion IN (SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%');
SAVEPOINT cofana;
UPDATE medicamento
SET precio = precio * 0.96
WHERE id_laboratorio = (SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE 'FARPASA FARMACEUTICA DEL PACIFICO')
AND id_clasificacion IN (SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%');
SAVEPOINT farpasa;
UPDATE medicamento
SET precio = precio * 0.898
WHERE id_laboratorio = (SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE 'RHONE POULENC ONCOLOGICOS')
AND id_clasificacion IN (SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%');
SAVEPOINT rhone;
UPDATE medicamento
SET precio = precio * 1.055
WHERE id_laboratorio = (SELECT id_laboratorio FROM laboratorio WHERE laboratorio LIKE 'ROEMMERS')
AND id_clasificacion IN (SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%');
SAVEPOINT roemmers;
UPDATE medicamento
SET precio = precio * 1.07
WHERE id_laboratorio IN (SELECT id_laboratorio FROM laboratorio
WHERE laboratorio NOT IN ('ABBOTT LABORATORIOS', 'BAYER QUIMICAS UNIDAS S.A.',
'COFANA (CONSORCIO FARMACEUTICO NACIONAL)', 'FARPASA FARMACEUTICA DEL PACIFICO',
'RHONE POULENC ONCOLOGICOS', 'ROEMMERS'))
AND id_clasificacion IN (SELECT id_clasificacion FROM clasificacion WHERE clasificacion LIKE '%ANALGESICO%');
COMMIT;

/*Ejercicio 3*/
/*a) */
BEGIN TRANSACTION;
INSERT INTO estudio_realizado VALUES(175363, 24, '2023-04-01', 15, 522, 'NORMAL', 'NO SE OBSERVAN IRREGULARIDADES', 3526.00);  --No se puede realizar la insercion, el paciente con el id dado no existe
SAVEPOINT estudio;
INSERT INTO tratamiento VALUES(175363, 1532, '2023-04-03', 253, 'AFRIN ADULTOS SOL', 'FRASCO X 15 CC', 1, 1821.79);
INSERT INTO tratamiento VALUES(175363, 1560, '2023-04-03', 253, 'NAFAZOL', 'FRASCO X 15 ML', 2, 1850.96);
INSERT INTO tratamiento VALUES(175363, 1522, '2023-04-03', 253, 'VIBROCIL GOTAS NASALES', 'FRASCO X 15 CC', 2, 2500.66);
SAVEPOINT tratamiento;
INSERT INTO internacion VALUES(175363, 157, '2023-04-03', 253, '2023-04-06', '11:30:00', 160000.00);
ROLLBACK;
COMMIT;

/*Ejercicio 4*/
BEGIN TRANSACTION;
INSERT INTO factura
	VALUES ((SELECT MAX(id_factura)+1 FROM factura), (SELECT id_persona FROM persona WHERE nombre='ALEJANDRA' AND apellido='HERRERA'), '06-04-2023', '17:30:01', 169699.41, 'N');
COMMIT;
--OBS: No parece necesario especificar las columnas en la sintaxis de INSERT si no vas a agregar valores en todas las columnas

/*Ejercicio 6*/
BEGIN TRANSACTION:
INSERT INTO mantenimiento_cama VALUES(53, CURRENT_DATE, 'sin novedad', 'EN REPARACION');
UPDATE cama SET estado = 'EN REPARACION' WHERE id_cama = 53;
INSERT INTO mantenimiento_cama VALUES(111, CURRENT_DATE, 'sin novedad', 'EN REPARACION');
UPDATE cama SET estado = 'EN REPARACION' WHERE id_cama = 111;
INSERT INTO mantenimiento_cama VALUES(163, CURRENT_DATE, 'sin novedad', 'EN REPARACION');
UPDATE cama SET estado = 'EN REPARACION' WHERE id_cama = 163;
SAVEPOINT camas;
INSERT INTO mantenimiento_equipo VALUES(12, CURRENT_DATE, 'sin novedad', 'EN REPARACION');
INSERT INTO mantenimiento_equipo VALUES(30, CURRENT_DATE, 'sin novedad', 'EN REPARACION');
COMMIT;

/*Ejercicio 7*/

BEGIN TRANSACTION;
INSERT INTO compra
VALUES((SELECT id_medicamento FROM medicamento WHERE nombre LIKE 'BILICANTA'),
(SELECT id_proveedor FROM proveedor WHERE proveedor LIKE 'MEDIFARMA'),
'2023-04-19', 350, (SELECT precio * 0.7 FROM medicamento WHERE nombre LIKE 'BILICANTA'), 240);
INSERT INTO compra
VALUES((SELECT id_medicamento FROM medicamento WHERE nombre LIKE 'IRRITREN 200 MG'),
(SELECT id_proveedor FROM proveedor WHERE proveedor LIKE 'DIFESA'),
'2023-04-19', 350, (SELECT precio * 0.7 FROM medicamento WHERE nombre LIKE 'IRRITREN 200 MG'), 90);
INSERT INTO compra
VALUES((SELECT id_medicamento FROM medicamento WHERE nombre LIKE 'PEDIAFEN JARABE'),
(SELECT id_proveedor FROM proveedor WHERE proveedor LIKE 'REYES DROGUERIA'),
'2023-04-19', 350, (SELECT precio * 0.7 FROM medicamento WHERE nombre LIKE 'PEDIAFEN JARABE'), 150);
COMMIT;






select * from pg_shadow;



















