<h1>📘 Inmobiliaria Calcifer & Howl — Parciales AD SQL (UTN 2025)</h1>
<p><strong>Parciales de práctica basados en el DDL oficial de <code>inmobiliaria_calciferhowl</code></strong></p>

<hr>

<h1>🧩 Parcial 1 — Registro de Propiedades, Asignaciones y Solicitudes</h1>

<h2>Ejercicio 1 — Propiedades con asignación inicial y agentes posteriores</h2>

<h3>Enunciado</h3>
<p>
Listar todas las propiedades con su agente inicial y los agentes posteriores que fueron asignados con el tiempo.  
Para cada propiedad mostrar:
</p>
<ul>
  <li>id y dirección de la propiedad</li>
  <li>agente inicial (el de menor fecha_hora_desde)</li>
  <li>cantidad total de agentes que la han gestionado</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>WITH primera_asignacion AS (
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
</code></pre>

<hr>

<h2>Ejercicio 2 — Procedimiento para registrar visitas por rango</h2>

<h3>Enunciado</h3>
<p>
Crear un procedimiento almacenado <code>visitas_por_periodo</code> que reciba un rango de fechas y devuelva todas las visitas realizadas en ese período, incluyendo:
</p>
<ul>
  <li>cliente (nombre y apellido)</li>
  <li>propiedad (dirección)</li>
  <li>agente con el que se realizó la visita</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>USE `inmobiliaria_calciferhowl`;
DROP procedure IF EXISTS `inmobiliaria_calciferhowl`.`visitas_por_periodo`;
;

DELIMITER $$
USE `inmobiliaria_calciferhowl`$$
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
END$$

DELIMITER ;
;


</code></pre>

<hr>
<h2>Ejercicio 3 — Valor actual, superficie total y valor por m²</h2>

<h3>Enunciado</h3>
<p>
Usar:
</p>
<ul>
  <li>último valor registrado en <code>valor_propiedad</code></li>
  <li>característica “superficie total” (id 14007)</li>
</ul>
<p>
Mostrar id, dirección, valor actual.
</p>

<h3>Resolución sugerida</h3>
<pre><code>with ultimo_valor as (
SELECT vp.id_propiedad, max(vp.fecha_hora_desde) fecha_ult 
FROM  valor_propiedad vp
INNER JOIN propiedad pdad ON pdad.id=vp.id_propiedad
GROUP BY vp.id_propiedad
)

SELECT pdad.id, pdad.direccion, vp.valor, pdad.superficie
FROM ultimo_valor uv
INNER JOIN valor_propiedad vp ON vp.id_propiedad=uv.id_propiedad AND uv.fecha_ult = vp.fecha_hora_desde
INNER JOIN propiedad pdad ON pdad.id = uv.id_propiedad
INNER JOIN caracteristica_propiedad cp ON cp.id_propiedad = uv.id_propiedad
WHERE cp.id_caracteristica=14007
</code></pre>

<hr>
<h1>🧩 Parcial 2 — Contratos, Garantías y Pagos</h1>

<h2>Ejercicio 1 — Solicitudes sin garantías suficientes</h2>

<h3>Enunciado</h3>
<p>
Listar solicitudes de contrato con menos garantías <strong>aprobadas</strong> que las requeridas:  
una solicitud debe tener al menos <strong>dos</strong> garantías aprobadas.
</p>

<p>Mostrar:</p>
<ul>
  <li>id solicitud</li>
  <li>cliente</li>
  <li>propiedad</li>
  <li>total de garantías</li>
  <li>garantías aprobadas</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>WITH total_garantias AS (
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
WHERE ga.cant_gar_ap &lt; 2;
</code></pre>

<hr>

<h2>Ejercicio 2 — Pagos de alquiler mensuales por solicitud</h2>

<h3>Enunciado</h3>
<p>
Para solicitudes en estado <code>en alquiler</code>, obtener:
</p>
<ul>
  <li>cliente</li>
  <li>propiedad</li>
  <li>cantidad de pagos realizados</li>
  <li>primer pago</li>
  <li>último pago</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>SELECT cli.nombre, cli.apellido, pdad.id, pdad.direccion, MIN(pago.fecha_hora_pago) primer_pago,
MAX(pago.fecha_hora_pago) ultimo_pago, COUNT(*) cant_pagos
FROM solicitud_contrato sol
INNER JOIN persona cli ON sol.id_cliente = cli.id
INNER JOIN propiedad pdad ON pdad.id = sol.id_propiedad
INNER JOIN pago ON pago.id_solicitud = sol.id
WHERE sol.estado = "en alquiler"
GROUP BY cli.nombre, cli.apellido, pdad.id, pdad.direccion
</code></pre>

<hr>

<h2>Ejercicio 3 — Entidad futura: Publicaciones del portal</h2>

<h3>Enunciado</h3>
<p>
Diseñar el modelo relacional para la entidad futura <code>publicacion</code> del portal, incluyendo:
</p>
<ul>
  <li>id autoincremental</li>
  <li>id_propiedad (FK)</li>
  <li>fecha_publicacion</li>
  <li>titulo</li>
  <li>descripcion</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>CREATE TABLE `inmobiliaria_calciferhowl`.`publicacion` (
  `id` INT UNSIGNED NOT NULL,
  `idpropiedad` INT UNSIGNED NULL,
  `fecha_publicacion` DATETIME NULL,
  `titulo` VARCHAR(45) NULL,
  `descripcion` VARCHAR(90) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_publicacion_propiedad_idx` (`idpropiedad` ASC) VISIBLE,
  CONSTRAINT `fk_publicacion_propiedad`
    FOREIGN KEY (`idpropiedad`)
    REFERENCES `inmobiliaria_calciferhowl`.`propiedad` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

</code></pre>

<hr>
<h2>🧩 Parcial 3</h2>

<h3>CH-AD01 – Agentes y propiedades gestionadas</h3>

<h4>Enunciado</h4>
<p>
Listar todas las propiedades con su agente inicial y la cantidad total de agentes que la han gestionado a lo largo del tiempo.
Para cada propiedad mostrar:
</p>
<ul>
  <li>id y dirección de la propiedad</li>
  <li>id, nombre y apellido del agente inicial (el de menor <code>fecha_hora_desde</code>)</li>
  <li>cantidad total de agentes que la han gestionado (contando todos los registros de <code>agente_asignado</code> para esa propiedad)</li>
</ul>

<h4>Resolución sugerida</h4>

<pre><code>WITH primera_asignacion AS (
    SELECT
        aga.id_propiedad,
        MIN(aga.fecha_hora_desde) AS fecha_min_asig
    FROM agente_asignado aga
    GROUP BY aga.id_propiedad
),
cant_agentes AS (
    SELECT
        aga.id_propiedad,
        COUNT(*) AS cant_ags
    FROM agente_asignado aga
    GROUP BY aga.id_propiedad
)

SELECT
    pdad.id,
    pdad.direccion,
    ag.id           AS id_agente_inicial,
    ag.nombre,
    ag.apellido,
    ca.cant_ags
FROM cant_agentes ca
INNER JOIN primera_asignacion pa
    ON pa.id_propiedad = ca.id_propiedad
INNER JOIN propiedad pdad
    ON pdad.id = ca.id_propiedad
INNER JOIN agente_asignado aga
    ON aga.id_propiedad     = pa.id_propiedad
   AND aga.fecha_hora_desde = pa.fecha_min_asig
INNER JOIN persona ag
    ON ag.id = aga.id_agente
ORDER BY pdad.id;
</code></pre>

<hr />

<h3>CH-AD02 – Procedimiento de visitas por período</h3>

<h4>Enunciado</h4>
<p>
Crear un procedimiento almacenado <code>visitas_por_periodo</code> que reciba un rango de fechas y devuelva todas las visitas realizadas en ese período, incluyendo:
</p>
<ul>
  <li>cliente (nombre y apellido)</li>
  <li>propiedad (dirección)</li>
  <li>agente con el que se realizó la visita (nombre y apellido)</li>
</ul>
<p>
Filtrar por la fecha y hora efectiva de la visita (<code>visita.fecha_hora_visita</code>) entre los parámetros recibidos.
</p>

<h4>Resolución sugerida</h4>

<pre><code>DELIMITER $$

CREATE PROCEDURE visitas_por_periodo
(
    IN fecha_desde DATETIME,
    IN fecha_hasta DATETIME
)
BEGIN
    SELECT
        cli.nombre,
        cli.apellido,
        pdad.direccion,
        CONCAT(ag.nombre, ' ', ag.apellido) AS nombre_agente
    FROM visita vis
    INNER JOIN persona cli
        ON cli.id = vis.id_cliente
    INNER JOIN persona ag
        ON ag.id = vis.id_agente
    INNER JOIN propiedad pdad
        ON pdad.id = vis.id_propiedad
    WHERE vis.fecha_hora_visita BETWEEN fecha_desde AND fecha_hasta;
END $$

DELIMITER ;
</code></pre>

<hr />

<h3>CH-AD03 – Normalizar la situación de las propiedades</h3>

<h4>Enunciado</h4>
<p>
Actualmente la situación de la propiedad (<code>propiedad.situacion</code>) se almacena como texto (por ejemplo: “a verificar”, “en oferta”, “señada”, “alquilada”).
</p>
<p>Se pide:</p>
<ol>
  <li>Crear una entidad <code>situacion_propiedad</code> con un id autoincremental y una descripción.</li>
  <li>Migrar las situaciones actualmente registradas en <code>propiedad.situacion</code> a la nueva tabla y agregar en <code>propiedad</code> la columna <code>id_situacion</code> como clave foránea.</li>
  <li>Cargar en <code>id_situacion</code> el valor correspondiente y eliminar la columna antigua <code>situacion</code>.</li>
</ol>
<p>
Realizar la migración dentro de una transacción.
</p>

<h4>Resolución sugerida</h4>

<pre><code>CREATE TABLE situacion_propiedad (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(20)  NOT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB;

ALTER TABLE propiedad
    ADD COLUMN id_situacion INT UNSIGNED NULL,
    ADD CONSTRAINT fk_propiedad_situacion
        FOREIGN KEY (id_situacion)
        REFERENCES situacion_propiedad(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

BEGIN;

INSERT INTO situacion_propiedad (descripcion)
SELECT DISTINCT situacion
FROM propiedad;

UPDATE propiedad p
INNER JOIN situacion_propiedad s
    ON p.situacion = s.descripcion
SET p.id_situacion = s.id;

COMMIT;

ALTER TABLE propiedad
    DROP COLUMN situacion,
    CHANGE COLUMN id_situacion id_situacion INT UNSIGNED NOT NULL;
</code></pre>

<hr />

<h2>🧩 Parcial 4</h2>

<h3>CH-AD04 – Solicitudes con garantías insuficientes</h3>

<h4>Enunciado</h4>
<p>
Una solicitud de contrato debería tener al menos dos garantías con estado <code>'aprobada'</code>.
</p>
<p>
Listar las solicitudes que no cumplen con esa condición (tienen menos de 2 garantías aprobadas), mostrando:
</p>
<ul>
  <li>id de la solicitud</li>
  <li>cliente (nombre y apellido)</li>
  <li>propiedad (id y dirección)</li>
  <li>cantidad total de garantías registradas para la solicitud</li>
  <li>cantidad de garantías aprobadas</li>
</ul>

<h4>Resolución sugerida</h4>

<pre><code>WITH total_garantias AS (
    SELECT
        gar.id_solicitud,
        COUNT(*) AS cant_total
    FROM garantia gar
    GROUP BY gar.id_solicitud
),
garantias_aprobadas AS (
    SELECT
        gar.id_solicitud,
        COUNT(*) AS cant_aprob
    FROM garantia gar
    WHERE gar.estado = 'aprobada'
    GROUP BY gar.id_solicitud
)

SELECT
    sol.id,
    CONCAT(cli.nombre, ' ', cli.apellido) AS cliente,
    pdad.id        AS id_propiedad,
    pdad.direccion,
    tg.cant_total,
    ga.cant_aprob
FROM solicitud_contrato sol
INNER JOIN persona cli
    ON cli.id = sol.id_cliente
INNER JOIN propiedad pdad
    ON pdad.id = sol.id_propiedad
INNER JOIN total_garantias tg
    ON tg.id_solicitud = sol.id
LEFT JOIN garantias_aprobadas ga
    ON ga.id_solicitud = sol.id
WHERE ga.cant_aprob &lt; 2
   OR ga.cant_aprob IS NULL;
</code></pre>

<hr />

<h3>CH-AD05 – Resumen de pagos para solicitudes en alquiler</h3>

<h4>Enunciado</h4>
<p>
Para las solicitudes de contrato que se encuentran en estado <code>'en alquiler'</code>, obtener:
</p>
<ul>
  <li>cliente (nombre y apellido)</li>
  <li>propiedad (id y dirección)</li>
  <li>cantidad de pagos realizados</li>
  <li>fecha y hora del primer pago</li>
  <li>fecha y hora del último pago</li>
</ul>

<h4>Resolución sugerida</h4>

<pre><code>SELECT
    sol.id,
    CONCAT(cli.nombre, ' ', cli.apellido) AS cliente,
    pdad.id         AS id_propiedad,
    pdad.direccion,
    COUNT(*)        AS cant_pagos,
    MIN(pago.fecha_hora_pago) AS primer_pago,
    MAX(pago.fecha_hora_pago) AS ultimo_pago
FROM solicitud_contrato sol
INNER JOIN persona cli
    ON cli.id = sol.id_cliente
INNER JOIN propiedad pdad
    ON pdad.id = sol.id_propiedad
INNER JOIN pago
    ON pago.id_solicitud = sol.id
WHERE sol.estado = 'en alquiler'
GROUP BY
    sol.id,
    cli.nombre,
    cli.apellido,
    pdad.id,
    pdad.direccion;
</code></pre>

<hr />

<h3>CH-AD06 – Valor actual de las propiedades</h3>

<h4>Enunciado</h4>
<p>
Usando el historial de valores de alquiler de las propiedades (<code>valor_propiedad</code>), obtener para cada propiedad:
</p>
<ul>
  <li>id de la propiedad</li>
  <li>dirección</li>
  <li>valor actual (el del último registro de <code>valor_propiedad</code> según <code>fecha_hora_desde</code>)</li>
</ul>

<h4>Resolución sugerida</h4>

<pre><code>WITH ultimo_valor AS (
    SELECT
        vp.id_propiedad,
        MAX(vp.fecha_hora_desde) AS fecha_ult
    FROM valor_propiedad vp
    GROUP BY vp.id_propiedad
)

SELECT
    pdad.id,
    pdad.direccion,
    vp.valor AS valor_actual
FROM ultimo_valor uv
INNER JOIN valor_propiedad vp
    ON vp.id_propiedad     = uv.id_propiedad
   AND vp.fecha_hora_desde = uv.fecha_ult
INNER JOIN propiedad pdad
    ON pdad.id = uv.id_propiedad;
</code></pre>
