<h1>📘 Inmobiliaria Calcifer & Howl — Parciales AD SQL (UTN 2025)</h1>
<p><strong>Parciales de práctica basados en el DDL oficial de <code>inmobiliaria_calciferhowl</code></strong></p>

<hr>

<h1>🧩 Parcial 1 — Registro de Propiedades, Asignaciones y Solicitudes</h1>

<h2>Ejercicio 1 — Procedimiento para registrar visitas por rango</h2>

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
<h2>Ejercicio 2 — Valor actual, superficie total y valor por m²</h2>

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

<pre><code>WITH datos_props AS (
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

<h2>💡 Bonus Track</h2>

<h3>Enunciado (versión con parámetros OUT)</h3>
<p>
Extender el procedimiento almacenado <code>visitas_por_periodo</code> para que, además de listar las visitas entre dos fechas, 
reciba dos parámetros <strong>OUT</strong>:
</p>
<ul>
  <li><code>total_visitas</code>: cantidad total de visitas en el período.</li>
  <li><code>total_clientes</code>: cantidad de clientes distintos que realizaron visitas en el período.</li>
</ul>

<p>El procedimiento debe:</p>
<ol>
  <li>Recibir un rango de fechas (<code>fecha_desde</code>, <code>fecha_hasta</code>).</li>
  <li>Devolver todas las visitas realizadas en ese período, indicando:
    <ul>
      <li>cliente (nombre y apellido)</li>
      <li>propiedad (dirección)</li>
      <li>agente con el que se realizó la visita (nombre y apellido)</li>
    </ul>
  </li>
  <li>Filtrar por la fecha y hora efectiva de la visita (<code>visita.fecha_hora_visita</code>).</li>
  <li>Asignar en los parámetros OUT:
    <ul>
      <li><code>total_visitas</code>: total de filas devueltas.</li>
      <li><code>total_clientes</code>: cantidad de <code>id_cliente</code> distintos en ese rango.</li>
    </ul>
  </li>
</ol>

<h3>Resolución sugerida</h3>

<pre><code>DELIMITER $$

CREATE PROCEDURE visitas_por_periodo
(
    IN  fecha_desde    DATETIME,
    IN  fecha_hasta    DATETIME,
    OUT total_visitas  INT,
    OUT total_clientes INT
)
BEGIN
    -- Listado de visitas en el período
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

    -- Cantidad total de visitas en el período
    SELECT COUNT(*)
    INTO total_visitas
    FROM visita vis
    WHERE vis.fecha_hora_visita BETWEEN fecha_desde AND fecha_hasta;

    -- Cantidad de clientes distintos que visitaron en el período
    SELECT COUNT(DISTINCT vis.id_cliente)
    INTO total_clientes
    FROM visita vis
    WHERE vis.fecha_hora_visita BETWEEN fecha_desde AND fecha_hasta;
END $$

DELIMITER ;
</code></pre>

<h3>Ejemplo de invocación</h3>

<p>Ejecutar el procedimiento para el período del 1/6/2025 al 31/7/2025:</p>

<pre><code>SET @total_visitas  = 0;
SET @total_clientes = 0;

CALL visitas_por_periodo(
    '2025-06-01 00:00:00',
    '2025-07-31 23:59:59',
    @total_visitas,
    @total_clientes
);

SELECT @total_visitas  AS total_visitas,
       @total_clientes AS total_clientes;
</code></pre>
<h2>💡 Bonus Track 2</h2>

<h3>Enunciado</h3>
<p>
Crear un trigger que asegure que todas las garantías nuevas se registren inicializadas correctamente.<br>
Definir un trigger <code>BEFORE INSERT</code> sobre la tabla <code>garantia</code> que:
</p>
<ul>
  <li>Fuerce el <code>estado</code> a <strong>'a validar'</strong> al insertar un nuevo registro.</li>
  <li>Deje siempre <code>fecha_baja</code> en <code>NULL</code> al momento del alta.</li>
</ul>
<p>
De este modo, aunque desde la aplicación se intenten insertar otros valores, la tabla <code>garantia</code>
comienza siempre con un estado consistente.
</p>

<h3>Resolución sugerida</h3>

<pre><code>DELIMITER $$

CREATE TRIGGER trg_garantia_before_insert
BEFORE INSERT ON garantia
FOR EACH ROW
BEGIN
    SET NEW.estado     = 'a validar';
    SET NEW.fecha_baja = NULL;
END $$

DELIMITER ;
</code></pre>

<hr />

<h2>💡 Bonus Track 3</h2>

<h3>Enunciado</h3>
<p>
Definir una función escalar que devuelva el valor actual de alquiler de una propiedad, usando el histórico
almacenado en <code>valor_propiedad</code>.
</p>

<p>Crear la función:</p>
<ul>
  <li><code>valor_actual_propiedad(p_id_propiedad INT)</code></li>
</ul>

<p>La función debe:</p>
<ol>
  <li>Buscar en <code>valor_propiedad</code> el registro de esa propiedad con la fecha/hora más reciente
      (<code>fecha_hora_desde</code>).</li>
  <li>Devolver el campo <code>valor</code> correspondiente.</li>
</ol>

<p>Tipo de retorno sugerido: <code>DECIMAL(10,3)</code>.</p>

<h3>Resolución sugerida</h3>

<pre><code>DELIMITER $$

CREATE FUNCTION valor_actual_propiedad(p_id_propiedad INT UNSIGNED)
RETURNS DECIMAL(10,3)
DETERMINISTIC
BEGIN
    DECLARE v_valor DECIMAL(10,3);

    SELECT vp.valor
    INTO v_valor
    FROM valor_propiedad vp
    WHERE vp.id_propiedad = p_id_propiedad
    ORDER BY vp.fecha_hora_desde DESC
    LIMIT 1;

    RETURN v_valor;
END $$

DELIMITER ;
</code></pre>

<h3>Ejemplo de uso</h3>

<pre><code>SELECT
    pdad.id,
    pdad.direccion,
    valor_actual_propiedad(pdad.id) AS valor_actual
FROM propiedad pdad;
</code></pre>

<hr />

<h2>💡 Bonus Track 4</h2>

<h3>Enunciado</h3>
<p>
Listar todas las propiedades, tengan o no solicitudes de contrato asociadas, mostrando:
</p>
<ul>
  <li><strong>id</strong> y <strong>dirección</strong> de la propiedad</li>
  <li><strong>cantidad de solicitudes de contrato</strong> que tuvo esa propiedad (incluyendo las que están en cualquier estado)</li>
</ul>

<p>
Se debe utilizar un <code>LEFT JOIN</code> entre <code>propiedad</code> y <code>solicitud_contrato</code> para que también
aparezcan las propiedades sin ninguna solicitud, con contador en cero.
</p>

<h3>Resolución sugerida</h3>

<pre><code>SELECT
    pdad.id,
    pdad.direccion,
    COUNT(sol.id) AS cant_solicitudes
FROM propiedad pdad
LEFT JOIN solicitud_contrato sol
    ON sol.id_propiedad = pdad.id
GROUP BY
    pdad.id,
    pdad.direccion;
</code></pre>

