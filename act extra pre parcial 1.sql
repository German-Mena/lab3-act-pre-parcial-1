Use BluePrint

--1) Por cada colaborador listar el apellido y nombre y la cantidad de proyectos distintos en los que haya trabajado.

select 
	CONCAT(CB.Nombre,' ',CB.Apellido) as Colaborador,
	count(distinct P.ID) as Cantidad
from Colaboradores as CB
	left join Colaboraciones as CO on CO.IDColaborador = CB.ID
	left join Tareas as T on T.ID = CO.IDTarea
	left join Modulos as M on M.ID = T.IDModulo
	left join Proyectos as P on P.ID = M.IDProyecto
group by CONCAT(CB.Nombre,' ',CB.Apellido)
order by Colaborador asc


--2) Por cada cliente, listar la razón social y el costo estimado del módulo más costoso que haya solicitado.

select 
	CL.RazonSocial as Cliente, 
	isnull(MAX(M.CostoEstimado), '-') as 'Costo estimado'
from Clientes as CL
	left join Proyectos as P on CL.ID = P.IDCliente
	left join Modulos as M on M.IDProyecto = P.ID
group by CL.RazonSocial
order by Cliente asc



--3) Los nombres de los tipos de tareas que hayan registrado más de diez colaboradores distintos en el año 2020. 

select TT.Nombre as 'Tipo de tarea' from TiposTarea as TT
	inner join Tareas as T on T.IDTipo = TT.ID
	inner join Colaboraciones as CB on CB.IDTarea = T.ID
where YEAR(T.FechaInicio) = 2020 or YEAR(T.FechaFin) like '2020'
group by TT.Nombre
having count(distinct CB.IDColaborador) > 10 
order by TT.Nombre asc



--4) Por cada cliente listar la razón social y el promedio abonado en concepto de proyectos. 
--   Si no tiene proyectos asociados mostrar el cliente con promedio nulo.

select CL.RazonSocial as Cliente, AVG(P.CostoEstimado) as 'Promedio abonado en proyectos'
from Clientes as CL
	left join Proyectos as P on P.IDCliente = CL.ID
group by CL.RazonSocial



--5) Los nombres de los tipos de tareas que hayan promediado más horas de colaboradores externos que internos.

select TT.Nombre as 'Tipo de tarea' from TiposTarea as TT
where (
	(
		select AVG(CB.Tiempo) from Tareas as T
		inner join Colaboraciones as CB on CB.IDTarea = T.ID
		inner join Colaboradores as CO on CO.ID = CB.IDColaborador
		where T.IDTipo = TT.ID and CO.Tipo like 'E'
	) > (
		select AVG(CB.Tiempo) from Tareas as T
		inner join Colaboraciones as CB on CB.IDTarea = T.ID
		inner join Colaboradores as CO on CO.ID = CB.IDColaborador
		where T.IDTipo = TT.ID and CO.Tipo like 'I'
	)
)



--6) El nombre de proyecto que más colaboradores distintos haya empleado.


-- VER RESOLUCIONES ALTERNATIVAS
select top(1) P.Nombre as Proyecto, count(distinct CB.IDColaborador) as Cantidad
from Proyectos as P
	inner join Modulos as M on M.IDProyecto = P.ID
	inner join Tareas as T on T.IDModulo = M.ID
	inner join Colaboraciones as CB on CB.IDTarea = T.ID
group by P.Nombre
order by Cantidad desc

/*
select MiTabla.Nombre
from (
	select P.Nombre from Proyectos as P
	inner join Modulos as M on M.IDProyecto = P.ID
	inner join Tareas as T on T.IDModulo = M.ID
	inner join Colaboraciones as CB on CB.IDTarea = T.ID
	group by P.Nombre
	where 
) as MiTabla
*/

/*
select P.Nombre from Proyectos as P
where P.ID in (
	select P.ID from Proyectos as P
	inner join Modulos as M on M.IDProyecto = P.ID
	inner join Tareas as T on T.IDModulo = M.ID
	inner join Colaboraciones as CB on CB.IDTarea = T.ID
	group by P.Nombre
	having count(distinct CB.IDColaborador) 
)
*/



--7) Por cada colaborador, listar el apellido y nombres y la cantidad de horas trabajadas en el año 2018, 
--   la cantidad de horas trabajadas en 2019 y la cantidad de horas trabajadas en 2020.

--MAL
select
	CONCAT(CO.Nombre,' ',CO.Apellido) as Colaborador,
	() as 'horas trabajadas en 2018',
	() as 'horas trabajadas en 2019',
	() as 'horas trabajadas en 2020'
from Colaboradores as CO
	left join Colaboraciones as CB on CB.IDColaborador = CO.ID
	left join Tareas as T on T.ID = CB.IDTarea
where YEAR(T.FechaInicio) = 2018 or
	YEAR(T.FechaInicio) = 2019 or
	YEAR(T.FechaInicio) = 2020 or
	YEAR(T.FechaFin) = 2018 or
	YEAR(T.FechaFin) = 2019 or
	YEAR(T.FechaFin) = 2020 
group by CONCAT(CO.Nombre,' ',CO.Apellido) 
--NO SE PUEDE HACER SIN SUBCONSULTAS PORQUE NO PUEDO DISCRIMINAR POR ANIO AL MOMENTO DE SUMAR


select
	CONCAT(CO.Nombre,' ',CO.Apellido) as Colaborador,
	(
		select SUM(CB.Tiempo) from Colaboraciones as CB
		inner join Tareas as T on T.ID = CB.IDTarea
		where CO.ID = CB.IDColaborador and (YEAR(T.FechaInicio) = 2018 or YEAR(T.FechaFin) = 2018)
	) as 'horas trabajadas en 2018',
	(
		select SUM(CB.Tiempo) from Colaboraciones as CB
		inner join Tareas as T on T.ID = CB.IDTarea
		where CO.ID = CB.IDColaborador and (YEAR(T.FechaInicio) = 2019 or YEAR(T.FechaFin) = 2019)
	) as 'horas trabajadas en 2019',
	(
		select SUM(CB.Tiempo) from Colaboraciones as CB
		inner join Tareas as T on T.ID = CB.IDTarea
		where CO.ID = CB.IDColaborador and (YEAR(T.FechaInicio) = 2020 or YEAR(T.FechaFin) = 2020)
	) as 'horas trabajadas en 2020'
from Colaboradores as CO



--8) Los apellidos y nombres de los colaboradores que hayan trabajado más horas en 2018 que en 2019 y más horas en 2019 que en 2020.

select CONCAT(CO.Apellido,' ',CO.Nombre) as Colaborador from Colaboradores as CO
where (
	(
		select sum(CB.Tiempo) from Colaboraciones as CB
		inner join Tareas as T on T.ID = CB.IDTarea
		where CB.IDColaborador = CO.ID and (YEAR(T.FechaInicio) = 2018 or YEAR(T.FechaFin) = 2018)
	) > (
		select sum(CB.Tiempo) from Colaboraciones as CB
		inner join Tareas as T on T.ID = CB.IDTarea
		where CB.IDColaborador = CO.ID and (YEAR(T.FechaInicio) = 2019 or YEAR(T.FechaFin) = 2019)
	) and (
		select sum(CB.Tiempo) from Colaboraciones as CB
		inner join Tareas as T on T.ID = CB.IDTarea
		where CB.IDColaborador = CO.ID and (YEAR(T.FechaInicio) = 2019 or YEAR(T.FechaFin) = 2019)
	) > (
		select sum(CB.Tiempo) from Colaboraciones as CB
		inner join Tareas as T on T.ID = CB.IDTarea
		where CB.IDColaborador = CO.ID and (YEAR(T.FechaInicio) = 2020 or YEAR(T.FechaFin) = 2020)
	)
)



--9) Los apellidos y nombres de los colaboradores que nunca hayan trabajado en un proyecto contratado por un cliente extranjero.

select CONCAT(CO.Apellido,' ',CO.Nombre) as Colaborador from Colaboradores as CO
where CO.ID not in (
	select distinct CO2.ID from Colaboradores as CO2
	inner join Colaboraciones as CB on CB.IDColaborador = CO2.ID
	inner join Tareas as T on T.ID = CB.IDTarea
	inner join Modulos as M on M.ID = T.IDModulo
	inner join Proyectos as PR on PR.ID = M.IDProyecto
	inner join Clientes as CL on CL.ID = PR.IDCliente
	inner join Ciudades as C on C.ID = CL.IDCiudad
	inner join Paises as P on P.ID = C.IDPais
	where P.Nombre like 'Argentina'
)

/*
select CONCAT(CO.Apellido,' ',CO.Nombre) as Colaborador from Colaboradores as CO
where CO.ID not in (
	select CO2.ID from Colaboradores as CO2
	inner join Colaboraciones as CB on CB.IDColaborador = CO2.ID
	inner join Tareas as T on T.ID = CB.IDTarea
	inner join Modulos as M on M.ID = T.IDModulo
	inner join Proyectos as PR on PR.ID = M.IDProyecto
	inner join Clientes as CL on CL.ID = PR.IDCliente
	inner join Ciudades as C on C.ID = CL.IDCiudad
	inner join Paises as P on P.ID = C.IDPais
	where P.Nombre not like 'Argentina' and CO.ID = CO2.ID
	group by CO2.ID
	having count(distinct CO2.ID) = 0
)
*/

select CONCAT(CO.Apellido,' ',CO.Nombre) as Colaborador from Colaboradores as CO
where (
	select count(CO2.ID) from Colaboradores as CO2
	inner join Colaboraciones as CB on CB.IDColaborador = CO2.ID
	inner join Tareas as T on T.ID = CB.IDTarea
	inner join Modulos as M on M.ID = T.IDModulo
	inner join Proyectos as PR on PR.ID = M.IDProyecto
	inner join Clientes as CL on CL.ID = PR.IDCliente
	inner join Ciudades as C on C.ID = CL.IDCiudad
	inner join Paises as P on P.ID = C.IDPais
	where P.Nombre not like 'Argentina' and CO.ID = CO2.ID
) = 0 



--10) Por cada tipo de tarea listar el nombre, el precio de hora base y el promedio de valor hora real (obtenido de las colaboraciones).
--    También, una columna llamada Variación con las siguientes reglas:
--	  Poca → Si la diferencia entre el promedio y el precio de hora base es menor a $500.
--    Mediana → Si la diferencia entre el promedio y el precio de hora base está entre $501 y $999.
--    Alta → Si la diferencia entre el promedio y el precio de hora base es $1000 o más.

select 
	TT.Nombre as 'Tipo de tarea', 
	TT.PrecioHoraBase as 'Precio hora base',
	AVG(CO.PrecioHora) as 'Promedio valor hora real',
	-- Este promedio se hace solo teniendo en cuenta el precio hora de aquellas
	-- colaboraciones que tengan el mismo ID de tipo de tarea porque esta esfecificado 
	-- eso en el group by?
	case 
		when (AVG(CO.PrecioHora) - TT.PrecioHoraBase) < 500 then 'Poca'
		when (AVG(CO.PrecioHora) - TT.PrecioHoraBase) > 500 and (AVG(CO.PrecioHora) - TT.PrecioHoraBase) < 1000  then 'Mediana'
		else 'Alta'
	end as Variacion
from TiposTarea as TT
	left join Tareas as T on T.IDTipo = TT.ID
	left join Colaboraciones as CO on CO.IDTarea = T.ID
	--where CO.IDTarea = T.IDTipo
	group by TT.Nombre,	TT.PrecioHoraBase
	order by TT.Nombre asc