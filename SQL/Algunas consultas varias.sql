--1) 
/*Muestre el id, nombre, apellido y dni de los pacientes que tienen obra social.*/
SELECT pe.id_persona, pe.nombre, pe.apellido, pe.dni FROM persona pe
INNER JOIN paciente pa ON pe.id_persona = pa.id_paciente
WHERE pa.id_obra_social IS NOT NULL;

/*2) Liste todos los pacientes con obra social 
que fueron atendidos en los consultorios 'CARDIOLOGIA' o 'NEUMONOLOGIA'.
Debe mostrar el nombre, apellido, dni y nombre de la obra social.*/
SELECT pe.id_persona, pe.nombre, pe.apellido, pe.dni FROM persona pe
INNER JOIN paciente pa ON pe.id_persona = pa.id_paciente
INNER JOIN consulta USING (id_paciente)
INNER JOIN consultorio con USING (id_consultorio)
WHERE pa.id_obra_social IS NOT NULL AND con.nombre IN ('CARDIOLOGIA', 'NEUMONOLOGIA');

/*3) Liste el id, nombre, apellido y sueldo de los empleados, como así también su cargo 
y especialidad. Ordenado alfabéticamente 
por cargo, luego por especialidad y en último término por sueldo de mayor a menor.*/
SELECT id_empleado, nombre,apellido, dni, sueldo,cargo, especialidad FROM empleado
INNER JOIN persona ON id_empleado = id_persona
INNER JOIN cargo USING (id_cargo)
INNER JOIN especialidad USING (id_especialidad)
ORDER BY cargo, especialidad, sueldo DESC;

/*4) Encuentre el empleado, cargo y turno de todos los empleados cuyo cargo sea AUXILIAR 
y el turno de trabajo aún se encuentre vigente.*/
SELECT id_empleado, cargo, turno FROM empleado
INNER JOIN cargo USING (id_cargo)
INNER JOIN trabajan USING  (id_empleado)
INNER JOIN turno USING (id_turno)
WHERE cargo LIKE '%AUXILIAR%' AND fin IS NULL;

/*5) Muestre la cantidad de compras realizadas por los empleados de la especialidad 
SIN ESPECIALIDAD MEDICA. Debe mostrar el nombre del empleado, 
el cargo que tiene y la cantidad de compras, ordenado por cantidad de mayor a menor.*/

SELECT nombre, cargo, COUNT (id_empleado) AS cant_compras FROM empleado
INNER JOIN persona ON id_empleado=id_persona
INNER JOIN cargo USING (id_cargo)
INNER JOIN compra USING (id_empleado)
INNER JOIN especialidad USING (id_especialidad)
WHERE especialidad LIKE '%SIN ESPECIALIDAD MEDICA%'
GROUP BY id_empleado,nombre,cargo
ORDER BY cant_compras DESC;

/*6) Muestre los pacientes que tienen obra social, que fueron internados 
en septiembre del 2019,
en el 7mo y 8vo piso. Ordenados por la fecha de internación de mayor a menor.*/
SELECT id_persona, CONCAT(nombre,' ',apellido) as nomb_ape,fecha_inicio, piso FROM persona
INNER JOIN paciente ON id_persona = id_paciente
INNER JOIN internacion USING (id_paciente)
INNER JOIN cama USING (id_cama)
INNER JOIN habitacion USING (id_habitacion)
WHERE fecha_inicio >= '2019-09-1' AND fecha_inicio <= '2019-09-30' AND piso IN (7,8)
ORDER BY fecha_inicio DESC;

/*7) Muestre los proveedores a los que no se les compró ningún medicamento.*/
SELECT * FROM proveedor 
WHERE id_proveedor NOT IN (SELECT id_proveedor FROM compra);

/*8) Liste los medicamentos que no fueron prescriptos nunca.*/
SELECT * FROM medicamento
WHERE id_medicamento NOT IN (SELECT id_medicamento FROM tratamiento);


/*9) Muestre los empleados que hayan realizado más 
internaciones que 'DAVID MASAVEU' antes del 15/02/2019.*/
SELECT id_empleado, CONCAT(nombre,' ',apellido) as nomb_ape, COUNT (id_empleado) AS cant_internaciones FROM persona
INNER JOIN empleado ON id_persona=id_empleado
INNER JOIN internacion ON id_empleado = ordena_internacion
WHERE fecha_inicio<'2019-02-15'
GROUP BY id_empleado, nombre, apellido
HAVING COUNT(id_empleado) > (SELECT COUNT(ordena_internacion) FROM internacion
							INNER JOIN empleado ON ordena_internacion=id_empleado
							INNER JOIN persona ON id_empleado = id_persona
							WHERE persona.nombre='DAVID' AND persona.apellido='MASAVEU' AND fecha_inicio<'2019-02-15');

/*10) Muestre los pacientes a los que les hayan facturado más que ‘LAURA MONICA 
JABALOYES’ desde el 15/05/2022 a la fecha.*/
SELECT id_paciente,  CONCAT(nombre,' ',apellido) as nomb_ape, SUM (monto) as precio_facturado FROM persona
INNER JOIN paciente ON id_persona= id_paciente
INNER JOIN factura USING (id_paciente)
WHERE fecha > '2022-05-15'
GROUP BY id_paciente, nombre, apellido
HAVING SUM(monto)>(SELECT SUM(monto) FROM factura
				  INNER JOIN paciente USING (id_paciente)
				  INNER JOIN persona ON id_persona=id_paciente
				  WHERE nombre='LAURA MONICA' AND apellido = 'JABALOYES' AND fecha>'2022-05-15');

/*11) Liste todos los empleados que no hayan comprado medicamentos del proveedor 
‘ARABESA’ entre el 01/02/2018 y el 10/03/2018. Ordénelos alfabéticamente.*/
SELECT id_empleado, p.nombre, p.apellido, fecha, proveedor FROM empleado e
INNER JOIN persona p ON e.id_empleado = p.id_persona
INNER JOIN compra USING(id_empleado)
INNER JOIN proveedor USING(id_proveedor)
WHERE fecha BETWEEN '2018-02-01' AND '2018-03-10' AND id_empleado NOT IN (
SELECT id_empleado FROM empleado
INNER JOIN compra USING(id_empleado)
INNER JOIN proveedor USING(id_proveedor)
WHERE fecha BETWEEN '2018-02-01' AND '2018-03-10' AND proveedor = 'ARABESA');

/*12) Muestre los 5 medicamentos más recetados y el laboratorio al que pertenecen.*/
SELECT id_medicamento, medicamento.nombre, COUNT(id_medicamento) as cant_vendidos FROM medicamento
INNER JOIN tratamiento USING (id_medicamento)
INNER JOIN laboratorio USING(id_laboratorio)
GROUP BY id_medicamento, medicamento.nombre
ORDER BY cant_vendidos DESC
LIMIT 5;

/*13) Muestre (en una sola consulta) el id, fecha de ingreso y 
estado de todas las camas y equipos que aún no fueron reparadas.*/

SELECT id_cama AS id, fecha_ingreso, estado, 'CAMA' AS tipo FROM mantenimiento_cama
WHERE fecha_egreso IS NULL
UNION
SELECT id_equipo, fecha_ingreso, estado, 'EQUIPO' FROM mantenimiento_equipo
WHERE fecha_egreso IS NULL;


/*14) Modifique el precio, aumentando un 5%, a los medicamentos cuyo laboratorio 
sea ‘LABOSINRATO’ 
y la clasificación sea ‘APARATO DIGESTIVO’ o ‘VENDAS’.*/
UPDATE medicamento SET precio=precio*1.05 WHERE id_laboratorio IN (SELECT id_laboratorio FROM laboratorio
																  WHERE laboratorio='LABOSINRATO') 
																  AND id_clasificacion IN (SELECT id_clasificacion FROM clasificacion
																						  WHERE clasificacion IN ('APARATO DIGESTIVO', 'VENDAS'));
																						  
/*15) Modifique el campo estado de la tabla mantenimiento_equipo, con la palabra
“baja” y en la fecha de egreso ponga la fecha del sistema, de aquellos equipos que 
ingresaron hace más de 100 días (recalcule usando la fecha de ingreso y la del 
sistema)*/
UPDATE mantenimiento_equipo SET estado='baja', fecha_egreso=CURRENT_DATE
	WHERE fecha_egreso IS NULL AND (CURRENT_DATE-fecha_ingreso)>100;

/*16) Elimine las clasificaciones que no se usan en los medicamentos.*/
DELETE FROM clasificacion
WHERE id_clasificacion NOT IN (SELECT id_clasificacion FROM medicamento);

/*17) Elimine las compras realizadas entre 01/03/2008 y 15/03/2008,
de los medicamentos cuya clasificación es ‘ENERGETICOS’.*/
DELETE FROM compra co
USING medicamento me
INNER JOIN clasificacion USING(id_clasificacion)
WHERE co.id_medicamento = me.id_medicamento
AND clasificacion = 'ENERGETICOS' AND fecha BETWEEN '2008-03-01' AND '2008-03-15';
