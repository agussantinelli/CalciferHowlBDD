/* todas las propiedades con su agente inicial y los agentes posteriores que fueron asignados con el tiempo.
 Para cada propiedad mostrar:

id y dirección de la propiedad
agente inicial (el de menor fecha_hora_desde)
cantidad total de agentes que la han gestionado
*/
WITH primera_asignacion AS (
SELECT aga.id_propiedad, MIN(aga.fecha_hora_desde) fecha_min_asig
FROM agente_asignado aga
GROUP BY aga.id_propiedad
),
 cant_agentes AS (
SELECT aga.id_propiedad, COUNT(*) cant_ags
FROM agente_asignado aga
GROUP BY aga.id_propiedad
)

SELECT pdad.id, pdad.direccion, ag.id, ag.nombre, ag.apellido, ca.cant_ags
FROM cant_agentes ca
INNER JOIN primera_asignacion pa ON pa.id_propiedad=ca.id_propiedad
INNER JOIN propiedad pdad ON pdad.id = ca.id_propiedad
INNER JOIN agente_asignado aga ON aga.id_propiedad=pa.id_propiedad AND pa.fecha_min_asig = aga.fecha_hora_desde
INNER JOIN persona ag ON aga.id_agente = ag.id