/*Ejercicio 2*/
/*Grupos necesarios*/
/*RECORDAR: Se pueden crear usuarios y grupos haciendo clic en 'login/group' y luego en 'create' */
CREATE ROLE varelata_informes WITH
	NOLOGIN     --Solo aplica en grupos, los grupos no pueden logearse
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION;

CREATE ROLE varelata_admision WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION;

CREATE ROLE varelata_rrhh WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION;
	
CREATE ROLE varelata_medicos WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION;
	
CREATE ROLE varelata_compras WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION;
	
CREATE ROLE varelata_facturacion WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION;
	
CREATE ROLE varelata_mantenimiento WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION;
	
CREATE ROLE varelata_sistemas WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION;
	
/*Usuarios necesarios*/
/*RECORDAR: Los permisos se pueden asignar haciendo clic en 'tables' y 'grant wizard'*/
CREATE ROLE varelata_user_informes WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'xxxxxx';
/*Para agregar un usuario al grupo se sigue la siguiente secuencia: */
/*GRANT nombre_grupo TO nombre_usuario WITH ADMIN OPTION*/
GRANT varelata_informes TO varelata_user_informes WITH ADMIN OPTION;

/**/GRANT SELECT ON persona, paciente,obra_social TO varelata_informes;
/**/GRANT SELECT ON consulta, diagnostico, tratamiento TO varelata_informes;
/**/GRANT SELECT ON internacion, habitacion, cama TO varelata_informes;
/**/GRANT SELECT ON estudio_realizado, equipo TO varelata_informes;
	GRANT SELECT (id_estudio, nombre) ON estudio TO varelata_informes;
/**/GRANT SELECT ON empleado, turno, trabajan TO varelata_informes;

CREATE ROLE varelata_user_admision WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'xxxxxx';
GRANT varelata_admision TO varelata_user_admision WITH ADMIN OPTION;

/**/GRANT INSERT, UPDATE ON persona,paciente TO varelata_admision;
GRANT DELETE ON paciente TO varelata_admision;
GRANT SELECT ON persona TO varelata_admision;
/**/GRANT SELECT ON consulta, tratamiento, diagnostico, estudio_realizado TO varelata_admision;
    GRANT SELECT(id_medicamento, nombre, presentacion) ON medicamento TO varelata_admision;
	GRANT SELECT(id_estudio, nombre) ON estudio TO varelata_admision;
/**/GRANT INSERT ON consulta TO varelata_admision;
/**/GRANT INSERT ON estudio_realizado TO varelata_admision;
	GRANT SELECT (id_equipo, nombre) ON equipo TO varelata_admision;
/**/GRANT SELECT, INSERT, UPDATE ON internacion TO varelata_admision;
	GRANT SELECT ON cama TO varelata_admision;


	
CREATE ROLE varelata_user_rrhh WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'xxxxxx';
GRANT varelata_rrhh TO varelata_user_rrhh WITH ADMIN OPTION;	

GRANT INSERT, UPDATE ON empleado, persona TO varelata_rrhh;
GRANT DELETE ON empleado TO varelata_rrhh;
GRANT SELECT ON persona, cargo, especialidad TO varelata_rrhh;

GRANT UPDATE ON trabajan TO varelata_rrhh;
GRANT SELECT ON turno TO varelata_rrhh;
	
CREATE ROLE varelata_user_medicos WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'xxxxxx';
GRANT varelata_medicos TO varelata_user_medicos WITH ADMIN OPTION;
	
GRANT INSERT ON consulta TO varelata_medicos;
GRANT SELECT(id_persona, nombre, apellido, dni) ON persona TO varelata_medicos;
GRANT SELECT(id_consultorio, nombre) ON consultorio TO varelata_medicos;
	
GRANT INSERT, UPDATE, DELETE ON tratamiento TO varelata_medicos;
GRANT SELECT(id_medicamento, nombre, presentacion) ON medicamento TO varelata_medicos;

GRANT INSERT, UPDATE, DELETE ON diagnostico TO varelata_medicos;
GRANT SELECT(id_paciente, id_empleado, fecha) ON consulta TO varelata_medicos;
GRANT SELECT ON patologia TO varelata_medicos;

GRANT INSERT, UPDATE, DELETE ON estudio_realizado TO varelata_medicos;
GRANT SELECT(id_equipo, nombre) ON equipo TO varelata_medicos;
GRANT SELECT(id_estudio, nombre) ON estudio TO varelata_medicos;

GRANT varelata_informes TO varelata_medicos WITH ADMIN OPTION;

GRANT varelata_admision TO varelata_medicos WITH ADMIN OPTION;
	
CREATE ROLE varelata_user_compras WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'xxxxxx';
GRANT varelata_compras TO varelata_user_compras WITH ADMIN OPTION;

GRANT SELECT ON compra, proveedor, medicamento, clasificacion, laboratorio TO varelata_compras;
GRANT INSERT ON laboratorio, clasificacion, proveedor, medicamento TO varelata_compras;
GRANT UPDATE ON laboratorio, clasificacion, proveedor, medicamento TO varelata_compras;
GRANT DELETE ON laboratorio, clasificacion, proveedor, medicamento TO varelata_compras;
	
CREATE ROLE varelata_user_facturacion WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'xxxxxx';
GRANT varelata_facturacion TO varelata_user_facturacion WITH ADMIN OPTION;

GRANT SELECT ON factura TO varelata_facturacion ;
GRANT SELECT(id_persona, nombre, apellido, dni) ON persona TO varelata_facturacion ;

GRANT INSERT, UPDATE, DELETE ON factura TO varelata_facturacion ;

GRANT SELECT ON pago TO varelata_facturacion ;

GRANT INSERT, UPDATE, DELETE ON pago TO varelata_facturacion ;
	
CREATE ROLE varelata_user_mantenimiento WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'xxxxxx';
GRANT varelata_mantenimiento TO varelata_user_mantenimiento WITH ADMIN OPTION;

GRANT SELECT ON equipo TO varelata_mantenimiento;
GRANT SELECT(id_equipo, fecha_ingreso, estado, observacion) ON mantenimiento_equipo TO varelata_mantenimiento;

GRANT SELECT ON cama TO varelata_mantenimiento;
GRANT SELECT(id_cama, fecha_ingreso, estado, observacion) ON mantenimiento_cama TO varelata_mantenimiento;

GRANT INSERT ON equipo TO varelata_mantenimiento;

GRANT INSERT ON cama TO  varelata_mantenimiento;
GRANT SELECT(id_habitacion, piso, numero) ON habitacion TO  varelata_mantenimiento;

	
CREATE ROLE varelata_user_sistemas WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'xxxxxx';

GRANT varelata_sistemas TO varelata_user_sistemas WITH ADMIN OPTION;


/*Ejercicio 3*/
/*a)*/
SELECT pe.nombre, pe.apellido, os.nombre FROM persona pe
INNER JOIN paciente ON id_persona=id_paciente
LEFT JOIN obra_social os USING (id_obra_social);

/*b)*/
SELECT nombre, apellido, cargo, especialidad, sueldo FROM persona
INNER JOIN empleado ON id_persona=id_empleado
INNER JOIN cargo USING (id_cargo)
INNER JOIN especialidad USING (id_especialidad);

/*c) */
SELECT nombre, apellido, fecha_inicio from persona
INNER JOIN paciente ON id_persona=id_paciente
INNER JOIN internacion USING (id_paciente)
WHERE fecha_alta BETWEEN '2019-01-01' AND '2021-12-31';

/*d) */
SELECT apellido, nombre, id_factura, fecha, monto,pagada FROM persona
INNER JOIN factura ON id_persona=id_paciente
WHERE pagada = 'S';


/*e)*/
SELECT p.nombre, apellido, fecha, pa.nombre
FROM persona p
INNER JOIN empleado e ON p.id_persona = e.id_empleado
INNER JOIN diagnostico USING(id_empleado)
INNER JOIN patologia pa USING(id_patologia)
WHERE pa.nombre LIKE '%Asma%';	


/*Ejercicio 4*/
/*A)*/
SELECT * FROM consulta WHERE fecha > '2021-01-01';

/*B)*/
/*Mostrar los tratamientos cuyo número de dosis sea mayor que 2. Debe mostrar el nombre del paciente al quien le prescribieron el tratamiento.*/
SELECT CONCAT(pa.nombre, ' ', pa.apellido) AS paciente, CONCAT(emp.nombre, ' ', emp.apellido) AS medico, dosis FROM tratamiento
INNER JOIN persona pa ON id_paciente=pa.id_persona
INNER JOIN persona emp ON prescribe=emp.id_persona
WHERE dosis > '2';

/*C)*/
SELECT CONCAT(pa.nombre, ' ', pa.apellido) AS paciente, id_factura, fecha, monto, pagada, saldo FROM factura
INNER JOIN persona pa ON id_paciente=id_persona
WHERE fecha > '2021-06-30';

/*d)*/
SELECT * FROM factura
WHERE pagada='N' AND saldo<>monto;

/*e)*/
SELECT id_medicamento,medicamento.nombre, laboratorio, clasificacion, fecha_indicacion FROM medicamento
INNER JOIN tratamiento USING (id_medicamento)
INNER JOIN laboratorio USING (id_laboratorio)
INNER JOIN clasificacion USING (id_clasificacion)
WHERE fecha_indicacion > '2020-05-02';


/*f)*/
SELECT * FROM (
SELECT p.nombre, p.apellido, 'Consulta' AS tipo, fecha, resultado AS cuestion
FROM persona p
INNER JOIN consulta c ON p.id_persona = c.id_paciente
WHERE p.nombre LIKE 'CARLOS ALBERTO' AND p.apellido LIKE 'MARINARO'
UNION
SELECT p.nombre, p.apellido, 'Tratamiento' AS tipo, fecha_indicacion, t.nombre
FROM persona p
INNER JOIN tratamiento t ON p.id_persona = t.id_paciente
WHERE p.nombre LIKE 'CARLOS ALBERTO' AND p.apellido LIKE 'MARINARO'
UNION
SELECT p.nombre, p.apellido, 'Internación' AS tipo, fecha_inicio, 'Alta: ' || fecha_alta::varchar
FROM persona p
INNER JOIN internacion i ON p.id_persona = i.id_paciente
WHERE p.nombre LIKE 'CARLOS ALBERTO' AND p.apellido LIKE 'MARINARO'
UNION
SELECT p.nombre, p.apellido, 'Estudio' AS tipo, fecha, e.nombre || ' - Resultado: ' || resultado
FROM persona p
INNER JOIN estudio_realizado er ON p.id_persona = er.id_paciente
INNER JOIN estudio e USING(id_estudio)
WHERE p.nombre LIKE 'CARLOS ALBERTO' AND p.apellido LIKE 'MARINARO'
) AS historia
ORDER BY fecha

/*g)*/
SELECT CONCAT(pa.nombre, ' ', pa.apellido) AS paciente, id_factura, pago.fecha FROM pago
INNER JOIN factura USING (id_factura)
INNER JOIN persona pa ON id_paciente=id_persona
WHERE pa.nombre='RODOLFO JULIO' AND pa.apellido='URTUBEY';

/*h) */
SELECT CONCAT(emp.nombre, ' ', emp.apellido) as medico, CONCAT(pa.nombre, ' ', pa.apellido) AS paciente, fecha, id_consultorio, hora, resultado FROM consulta
INNER JOIN persona emp ON id_empleado=emp.id_persona
INNER JOIN persona pa ON id_paciente=pa.id_persona
WHERE emp.nombre='LAURA LEONOR' AND emp.apellido='ESTRADA';

/*i) */
SELECT * FROM cama WHERE estado='FUERA DE SERVICIO';

/*J) */
SELECT * FROM equipo
INNER JOIN mantenimiento_equipo USING (id_equipo)
WHERE fecha_egreso IS NULL;

/*K) */
SELECT med.nombre, proveedor, CONCAT (emp.nombre, ' ', emp.apellido) as empleado FROM compra
INNER JOIN persona emp ON id_empleado=id_persona
INNER JOIN medicamento med USING (id_medicamento)
INNER JOIN proveedor USING (id_proveedor)
WHERE compra.fecha BETWEEN '2020-01-01' AND '2020-12-31';





