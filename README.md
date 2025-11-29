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
<pre><code>with asignacion_minima as (
    select 
        id_propiedad,
        min(fecha_hora_desde) as inicio
    from agente_asignado
    group by id_propiedad
)
select 
    p.id,
    p.direccion,
    ag_ini.id_agente as agente_inicial,
    (select count(*) 
     from agente_asignado aa
     where aa.id_propiedad = p.id) as total_agentes
from propiedad p
inner join asignacion_minima am 
    on am.id_propiedad = p.id
inner join agente_asignado ag_ini
    on ag_ini.id_propiedad = am.id_propiedad
   and ag_ini.fecha_hora_desde = am.inicio
order by p.id;
</code></pre>

<hr>

<h2>Ejercicio 2 — Características con contenido por propiedad</h2>

<h3>Enunciado</h3>
<p>
Obtener todas las características registradas para cada propiedad, mostrando:
</p>
<ul>
  <li>propiedad (id, dirección)</li>
  <li>característica (nombre y tipo)</li>
  <li>contenido asignado</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>select
    p.id,
    p.direccion,
    c.nombre as caracteristica,
    c.tipo,
    cp.contenido
from caracteristica_propiedad cp
inner join propiedad p
    on cp.id_propiedad = p.id
inner join caracteristica c
    on c.id = cp.id_caracteristica
order by p.id, c.nombre;
</code></pre>

<hr>

<h2>Ejercicio 3 — Procedimiento para registrar visitas por rango</h2>

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
<pre><code>delimiter $$

create procedure visitas_por_periodo (
    in p_desde datetime,
    in p_hasta datetime
)
begin
    select
        cli.nombre as nombre_cliente,
        cli.apellido as apellido_cliente,
        p.direccion,
        ag.nombre as nombre_agente,
        ag.apellido as apellido_agente,
        v.fecha_hora_visita
    from visita v
    inner join persona cli
        on cli.id = v.id_cliente
    inner join persona ag
        on ag.id = v.id_agente
    inner join propiedad p
        on p.id = v.id_propiedad
    where v.fecha_hora_visita between p_desde and p_hasta
    order by v.fecha_hora_visita;
end $$

delimiter ;
</code></pre>

<hr><hr>

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
<pre><code>select
    sc.id,
    cli.nombre,
    cli.apellido,
    p.direccion,
    (select count(*) from garantia g where g.id_solicitud = sc.id) as total_garantias,
    (select count(*) 
     from garantia g 
     where g.id_solicitud = sc.id and g.estado = 'aprobada') as garantias_aprobadas
from solicitud_contrato sc
inner join persona cli
    on sc.id_cliente = cli.id
inner join propiedad p
    on sc.id_propiedad = p.id
having garantias_aprobadas &lt; 2;
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
<pre><code>select
    sc.id,
    cli.nombre,
    cli.apellido,
    p.direccion,
    count(pa.fecha_hora_pago) as cantidad_pagos,
    min(pa.fecha_hora_pago) as primer_pago,
    max(pa.fecha_hora_pago) as ultimo_pago
from solicitud_contrato sc
inner join persona cli
    on sc.id_cliente = cli.id
inner join propiedad p
    on sc.id_propiedad = p.id
inner join pago pa
    on pa.id_solicitud = sc.id
where sc.estado = 'en alquiler'
group by sc.id, cli.nombre, cli.apellido, p.direccion;
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
<pre><code>create table publicacion (
    id int unsigned not null auto_increment,
    id_propiedad int unsigned not null,
    fecha_publicacion datetime not null,
    titulo varchar(255) not null,
    descripcion text,
    primary key(id),
    constraint fk_publicacion_propiedad
        foreign key(id_propiedad) references propiedad(id)
);
</code></pre>

<hr><hr>

<h1>🧩 Parcial 3 — Habitaciones, Valores y Expansión del Modelo</h1>

<h2>Ejercicio 1 — Valor actual, superficie total y valor por m²</h2>

<h3>Enunciado</h3>
<p>
Usar:
</p>
<ul>
  <li>último valor registrado en <code>valor_propiedad</code></li>
  <li>característica “superficie total” (id 14007)</li>
</ul>
<p>
Mostrar id, dirección, valor actual, superficie y valor por m².
</p>

<h3>Resolución sugerida</h3>
<pre><code>with ult_valor as (
    select id_propiedad, max(fecha_hora_desde) as f
    from valor_propiedad
    group by id_propiedad
)
select
    p.id,
    p.direccion,
    v.valor as valor_actual,
    cast(cp.contenido as decimal(10,2)) as superficie_total,
    v.valor / cast(cp.contenido as decimal(10,2)) as valor_m2
from propiedad p
inner join ult_valor u
    on u.id_propiedad = p.id
inner join valor_propiedad v
    on v.id_propiedad = p.id
   and v.fecha_hora_desde = u.f
inner join caracteristica_propiedad cp
    on cp.id_propiedad = p.id
   and cp.id_caracteristica = 14007;
</code></pre>

<hr>

<h2>Ejercicio 2 — Propiedades con más de 10 habitaciones</h2>

<h3>Enunciado</h3>
<p>
Listar propiedades cuya suma total de habitaciones (habitacion.cantidad) supere las 10.
</p>

<h3>Resolución sugerida</h3>
<pre><code>select
    h.id_propiedad,
    p.direccion,
    sum(h.cantidad) as total_habitaciones
from habitacion h
inner join propiedad p
    on p.id = h.id_propiedad
group by h.id_propiedad, p.direccion
having total_habitaciones &gt; 10;
</code></pre>

<hr>

<h2>Ejercicio 3 — Entidad futura: Solicitud de Compra</h2>

<h3>Enunciado</h3>
<p>
Diseñar la entidad futura <code>solicitud_compra</code> para gestionar compraventas.
</p>

<p>Debe incluir:</p>
<ul>
  <li>id autoincremental</li>
  <li>cliente (FK)</li>
  <li>propiedad (FK)</li>
  <li>fecha_solicitud</li>
  <li>monto_ofrecido</li>
  <li>estado</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>create table solicitud_compra (
    id int unsigned not null auto_increment,
    id_cliente int unsigned not null,
    id_propiedad int unsigned not null,
    fecha_solicitud date not null,
    monto_ofrecido decimal(12,3) not null,
    estado varchar(20) not null,
    primary key(id),
    foreign key(id_cliente) references persona(id),
    foreign key(id_propiedad) references propiedad(id)
);
</code></pre>
