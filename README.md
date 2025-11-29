<h1>📘 Inmobiliaria Calcifer Howl — Parciales AD SQL</h1>
<p><strong>Parciales de práctica basados en el DDL de <code>inmobiliaria_calciferhowl</code></strong></p>

<hr>

<h1>🧩 Parcial 1</h1>

<h2>Ejercicio 1 – Contratos vigentes con datos de agente, cliente y propiedad</h2>

<h3>Enunciado</h3>
<p>
Listar todas las solicitudes de contrato que se encuentran actualmente <code>'en alquiler'</code>.  
Para cada una indicar:
</p>
<ul>
  <li><strong>Solicitud</strong>: id, nro_contrato, fecha_contrato, importe_mensual, estado.</li>
  <li><strong>Agente</strong>: id, nombre y apellido.</li>
  <li><strong>Cliente</strong>: id, nombre y apellido.</li>
  <li><strong>Propiedad</strong>: id, dirección y zona.</li>
</ul>
<p>
Ordenar el resultado por <code>fecha_contrato</code> ascendente.
</p>

<h3>Resolución sugerida</h3>
<pre><code>select
    sc.id,
    sc.nro_contrato,
    sc.fecha_contrato,
    sc.importe_mensual,
    sc.estado,
    ag.id   as id_agente,
    ag.nombre as nombre_agente,
    ag.apellido as apellido_agente,
    cli.id  as id_cliente,
    cli.nombre as nombre_cliente,
    cli.apellido as apellido_cliente,
    p.id    as id_propiedad,
    p.direccion,
    p.zona
from solicitud_contrato sc
inner join persona ag
    on sc.id_agente = ag.id
inner join persona cli
    on sc.id_cliente = cli.id
inner join propiedad p
    on sc.id_propiedad = p.id
where sc.estado = 'en alquiler'
order by sc.fecha_contrato;
</code></pre>

<hr>

<h2>Ejercicio 2 – Último valor registrado por propiedad</h2>

<h3>Enunciado</h3>
<p>
Obtener, para cada propiedad, el último valor registrado en la tabla <code>valor_propiedad</code>.  
Listar:
</p>
<ul>
  <li>id de la propiedad, dirección y situación.</li>
  <li>fecha_hora_desde y valor del último registro de esa propiedad.</li>
</ul>
<p>
Ordenar por id de propiedad.
</p>

<h3>Resolución sugerida</h3>
<pre><code>with max_valor as (
    select
        id_propiedad,
        max(fecha_hora_desde) as ultima_fecha
    from valor_propiedad
    group by id_propiedad
)
select
    p.id,
    p.direccion,
    p.situacion,
    vp.fecha_hora_desde,
    vp.valor
from propiedad p
inner join max_valor mv
    on p.id = mv.id_propiedad
inner join valor_propiedad vp
    on vp.id_propiedad = mv.id_propiedad
   and vp.fecha_hora_desde = mv.ultima_fecha
order by p.id;
</code></pre>

<hr>

<h2>Ejercicio 3 – Procedimiento de pagos por solicitud y rango de fechas</h2>

<h3>Enunciado</h3>
<p>
Crear un procedimiento almacenado <code>pagos_solicitud</code> que reciba:
</p>
<ul>
  <li><code>p_id_solicitud</code> (id de la solicitud de contrato)</li>
  <li><code>p_desde</code> (fecha y hora desde)</li>
  <li><code>p_hasta</code> (fecha y hora hasta)</li>
</ul>
<p>El procedimiento debe:</p>
<ol>
  <li>Listar todos los pagos de esa solicitud en el rango indicado, mostrando id_solicitud, fecha_hora_pago, concepto e importe.</li>
  <li>En un segundo resultado, mostrar el id_solicitud y el total de importes pagados en ese rango.</li>
</ol>
<p>Probarlo, por ejemplo, para la solicitud 22001 entre <code>2023-03-01</code> y <code>2023-12-31</code>.</p>

<h3>Resolución sugerida</h3>
<pre><code>delimiter $$

create procedure pagos_solicitud (
    in p_id_solicitud int unsigned,
    in p_desde datetime,
    in p_hasta datetime
)
begin
    -- Detalle de pagos
    select
        pa.id_solicitud,
        pa.fecha_hora_pago,
        pa.concepto,
        pa.importe
    from pago pa
    where pa.id_solicitud = p_id_solicitud
      and pa.fecha_hora_pago between p_desde and p_hasta
    order by pa.fecha_hora_pago;

    -- Total del período
    select
        pa.id_solicitud,
        sum(pa.importe) as total_importe
    from pago pa
    where pa.id_solicitud = p_id_solicitud
      and pa.fecha_hora_pago between p_desde and p_hasta
    group by pa.id_solicitud;
end $$

delimiter ;

call pagos_solicitud(22001, '2023-03-01 00:00:00', '2023-12-31 23:59:59');
</code></pre>

<hr>

<h1>🧩 Parcial 2</h1>

<h2>Ejercicio 1 – Solicitudes con pocas garantías aprobadas</h2>

<h3>Enunciado</h3>
<p>
La inmobiliaria quiere identificar las solicitudes de contrato que todavía no tienen suficientes garantías aprobadas.  
Se pide listar las solicitudes cuyo estado sea <code>'en alquiler'</code> o <code>'en proceso'</code> y que tengan menos de 2 garantías con estado <code>'aprobada'</code>.
</p>
<p>Para cada solicitud mostrar:</p>
<ul>
  <li>id y estado de la solicitud.</li>
  <li>cantidad total de garantías asociadas.</li>
  <li>cantidad de garantías con estado <code>'aprobada'</code>.</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>select
    sc.id,
    sc.estado,
    (select count(*)
     from garantia g
     where g.id_solicitud = sc.id) as total_garantias,
    (select count(*)
     from garantia g
     where g.id_solicitud = sc.id
       and g.estado = 'aprobada') as garantias_aprobadas
from solicitud_contrato sc
where sc.estado in ('en alquiler', 'en proceso')
having garantias_aprobadas &lt; 2;
</code></pre>

<hr>

<h2>Ejercicio 2 – Propiedades sin visitas registradas</h2>

<h3>Enunciado</h3>
<p>
Listar todas las propiedades que nunca tuvieron una visita registrada en la tabla <code>visita</code>.  
Para cada una mostrar id, dirección, zona y situación.
</p>

<h3>Resolución sugerida</h3>
<pre><code>select
    p.id,
    p.direccion,
    p.zona,
    p.situacion
from propiedad p
where not exists (
    select 1
    from visita v
    where v.id_propiedad = p.id
);
</code></pre>

<hr>

<h2>Ejercicio 3 – Normalización del tipo de propiedad</h2>

<h3>Enunciado</h3>
<p>
Se desea normalizar el atributo <code>tipo</code> de la tabla <code>propiedad</code> para convertirlo en una entidad propia.  
Realizar un script que:
</p>
<ol>
  <li>Genere la tabla <code>tipo_propiedad</code> con un id autoincremental y un nombre.</li>
  <li>Agregue a <code>propiedad</code> la columna <code>id_tipo_propiedad</code> con FK hacia <code>tipo_propiedad</code>.</li>
  <li>Inserte en <code>tipo_propiedad</code> los valores distintos de <code>propiedad.tipo</code>.</li>
  <li>Actualice <code>propiedad.id_tipo_propiedad</code> según el tipo original.</li>
  <li>Elimine la columna <code>tipo</code> y deje <code>id_tipo_propiedad</code> como NOT NULL.</li>
</ol>

<h3>Resolución sugerida</h3>
<pre><code>create table tipo_propiedad (
    id int unsigned not null auto_increment,
    nombre varchar(255) not null,
    primary key (id)
);

alter table propiedad
add column id_tipo_propiedad int unsigned null,
add constraint fk_propiedad_tipo_propiedad
    foreign key (id_tipo_propiedad) references tipo_propiedad(id);

begin;

insert into tipo_propiedad(nombre)
select distinct tipo
from propiedad;

update propiedad p
inner join tipo_propiedad tp
    on p.tipo = tp.nombre
set p.id_tipo_propiedad = tp.id;

commit;

alter table propiedad
drop column tipo,
modify column id_tipo_propiedad int unsigned not null;
</code></pre>

<hr>

<h1>🧩 Parcial 3</h1>

<h2>Ejercicio 1 – Evolución del valor de propiedades alquiladas</h2>

<h3>Enunciado</h3>
<p>
Para las propiedades cuya situación sea <code>'alquilada'</code>, obtener la evolución de su valor.  
Para cada propiedad listar:
</p>
<ul>
  <li>id, dirección.</li>
  <li>fecha y valor del primer registro en <code>valor_propiedad</code>.</li>
  <li>fecha y valor del último registro en <code>valor_propiedad</code>.</li>
  <li>la diferencia entre valor_último y valor_primero.</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>with extremos as (
    select
        id_propiedad,
        min(fecha_hora_desde) as fecha_primera,
        max(fecha_hora_desde) as fecha_ultima
    from valor_propiedad
    group by id_propiedad
)
select
    p.id,
    p.direccion,
    vp_ini.fecha_hora_desde as fecha_primera,
    vp_ini.valor            as valor_primero,
    vp_fin.fecha_hora_desde as fecha_ultima,
    vp_fin.valor            as valor_ultimo,
    (vp_fin.valor - vp_ini.valor) as diferencia
from propiedad p
inner join extremos ex
    on p.id = ex.id_propiedad
inner join valor_propiedad vp_ini
    on vp_ini.id_propiedad = ex.id_propiedad
   and vp_ini.fecha_hora_desde = ex.fecha_primera
inner join valor_propiedad vp_fin
    on vp_fin.id_propiedad = ex.id_propiedad
   and vp_fin.fecha_hora_desde = ex.fecha_ultima
where p.situacion = 'alquilada'
order by p.id;
</code></pre>

<hr>

<h2>Ejercicio 2 – Resumen de visitas por agente y propiedad</h2>

<h3>Enunciado</h3>
<p>
La inmobiliaria quiere un resumen de visitas realizadas por cada agente a cada propiedad.  
Para cada combinación agente–propiedad mostrar:
</p>
<ul>
  <li>id, nombre y apellido del agente.</li>
  <li>id y dirección de la propiedad.</li>
  <li>cantidad de visitas realizadas.</li>
  <li>fecha y hora de la última visita.</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>select
    ag.id        as id_agente,
    ag.nombre    as nombre_agente,
    ag.apellido  as apellido_agente,
    p.id         as id_propiedad,
    p.direccion,
    count(*)     as cantidad_visitas,
    max(v.fecha_hora_visita) as ultima_visita
from visita v
inner join persona ag
    on v.id_agente = ag.id
inner join propiedad p
    on v.id_propiedad = p.id
group by
    ag.id, ag.nombre, ag.apellido,
    p.id, p.direccion
order by
    ag.id,
    p.id;
</code></pre>

<hr>

<h2>Ejercicio 3 – Procedimiento de propiedades por zona y pileta</h2>

<h3>Enunciado</h3>
<p>
Crear un procedimiento almacenado <code>propiedades_con_caracteristicas</code> que reciba:
</p>
<ul>
  <li><code>p_zona</code>: zona de la propiedad.</li>
  <li><code>p_pileta</code>: valor de la característica <code>'pileta'</code> (por ejemplo, <code>'si'</code> o <code>'no'</code>).</li>
</ul>
<p>
El procedimiento debe listar las propiedades de esa zona cuya característica <code>pileta</code> (id_caracteristica = 14001)
tenga el valor indicado, mostrando además el nombre de la propiedad (característica con id_caracteristica = 14016, si existe).
</p>
<p>Mostrar:</p>
<ul>
  <li>id, dirección y zona de la propiedad.</li>
  <li>nombre de la propiedad (si está cargado).</li>
  <li>valor de la característica pileta.</li>
</ul>

<h3>Resolución sugerida</h3>
<pre><code>delimiter $$

create procedure propiedades_con_caracteristicas (
    in p_zona   varchar(255),
    in p_pileta varchar(10)
)
begin
    select
        p.id,
        p.direccion,
        p.zona,
        cp_nombre.contenido as nombre_propiedad,
        cp_pileta.contenido as tiene_pileta
    from propiedad p
    left join caracteristica_propiedad cp_pileta
        on cp_pileta.id_propiedad = p.id
       and cp_pileta.id_caracteristica = 14001   -- pileta
    left join caracteristica_propiedad cp_nombre
        on cp_nombre.id_propiedad = p.id
       and cp_nombre.id_caracteristica = 14016   -- nombre
    where p.zona = p_zona
      and cp_pileta.contenido = p_pileta;
end $$

delimiter ;

call propiedades_con_caracteristicas('Espacio Móvil', 'si');
</code></pre>
