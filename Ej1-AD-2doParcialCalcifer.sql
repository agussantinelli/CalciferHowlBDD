/*
Listar solicitudes de contrato con menos garantías aprobadas que las requeridas: una solicitud debe tener al menos 
dos garantías aprobadas.
Mostrar:
- id solicitud
- cliente
- propiedad
- total de garantías
- garantías aprobadas
*/
WITH total_garantias AS (
    SELECT 
        sol.id                         AS id_solicitud,
        COUNT(gar.id_garante)          AS cant_gar_total
    FROM solicitud_contrato sol
    LEFT JOIN garantia gar
        ON gar.id_solicitud = sol.id
    GROUP BY sol.id
),
garantias_aprobadas AS (
    SELECT
        sol.id                         AS id_solicitud,
        COUNT(gar.id_garante)          AS cant_gar_ap
    FROM solicitud_contrato sol
    LEFT JOIN garantia gar
        ON gar.id_solicitud = sol.id
       AND gar.estado = 'aprobada'
    GROUP BY sol.id
)

SELECT 
    sol.id,
    CONCAT(cli.nombre, ' ', cli.apellido) AS nombre_cliente,
    pdad.id                               AS id_propiedad,
    tg.cant_gar_total,
    ga.cant_gar_ap
FROM solicitud_contrato sol
INNER JOIN persona cli
    ON cli.id = sol.id_cliente
INNER JOIN propiedad pdad
    ON pdad.id = sol.id_propiedad
INNER JOIN total_garantias tg
    ON tg.id_solicitud = sol.id
INNER JOIN garantias_aprobadas ga
    ON ga.id_solicitud = sol.id
WHERE ga.cant_gar_ap < 2;
