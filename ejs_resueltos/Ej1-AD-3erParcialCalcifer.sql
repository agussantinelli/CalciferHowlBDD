/*
Listar todas las propiedades con su agente inicial y la cantidad total de agentes que la han gestionado a lo 
largo del tiempo. 
Para cada propiedad mostrar:
- id y dirección de la propiedad
- id, nombre y apellido del agente inicial (el de menor fecha_hora_desde)
- cantidad total de agentes que la han gestionado (contando todos los registros de agente_asignado para esa propiedad)
*/
WITH datos_props AS (
SELECT aga.id_propiedad, COUNT(*) cant_ags, MIN(aga.fecha_hora_desde) prim_fecha
FROM agente_asignado aga
group by aga.id_propiedad
)
SELECT pdad.id, pdad.direccion, ag.id as id_agente, ag.nombre as nombre_agente, ag.apellido as apellido_agente,
dp.cant_ags
FROM datos_props dp 
INNER JOIN agente_asignado aga ON dp.id_propiedad=aga.id_propiedad AND aga.fecha_hora_desde=dp.prim_fecha
INNER JOIN propiedad pdad ON pdad.id=aga.id_propiedad
INNER JOIN persona ag ON ag.id=aga.id_agente