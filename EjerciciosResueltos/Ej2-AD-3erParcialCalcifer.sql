CREATE PROCEDURE `visitas_por_periodo` 
(
IN fecha_inicio DATETIME,
IN fecha_fin DATETIME
)
BEGIN
SELECT cli.nombre, cli.apellido, pdad.direccion, ag.nombre, ag.apellido
FROM visita vis
INNER JOIN persona cli ON cli.id = vis.id_cliente
INNER JOIN persona ag ON ag.id = vis.id_agente
INNER JOIN propiedad pdad ON pdad.id = vis.id_propiedad
WHERE vis.fecha_hora_visita  between fecha_inicio and fecha_fin;
END
/*
CH-AD02 – Procedimiento de visitas por período
Enunciado
Crear un procedimiento almacenado visitas_por_periodo que reciba un rango de fechas y devuelva todas 
las visitas realizadas en ese período, incluyendo:

- cliente (nombre y apellido)
- propiedad (dirección)
- agente con el que se realizó la visita (nombre y apellido)
- Filtrar por la fecha y hora efectiva de la visita (visita.fecha_hora_visita) entre los 
  parámetros recibidos.
*/