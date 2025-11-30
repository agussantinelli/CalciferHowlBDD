/*
Usar:
último valor registrado en valor_propiedad
característica “superficie total” (id 14007)
Mostrar id, dirección, valor actual, superficie y valor por m².
*/
with ultimo_valor as (
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