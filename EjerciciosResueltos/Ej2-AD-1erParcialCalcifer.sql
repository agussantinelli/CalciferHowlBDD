CREATE DEFINER=`root`@`localhost` PROCEDURE `visitas_por_periodo`(
IN fecha_desde DATETIME,
IN fecha_hasta DATETIME
)
BEGIN
SELECT 
cli.nombre, cli.apellido, pdad.direccion, CONCAT(ag.nombre, " ", ag.apellido) "Nombre Agente"
FROM visita vis
INNER JOIN persona cli ON cli.id = vis.id_cliente
INNER JOIN persona ag ON ag.id = vis.id_agente
INNER JOIN propiedad pdad ON pdad.id = vis.id_propiedad
WHERE vis.fecha_hora_visita BETWEEN fecha_desde AND fecha_hasta;
END