/*
Para solicitudes en estado en alquiler, obtener:
- cliente
- propiedad
- cantidad de pagos realizados
- primer pago
- último pago
*/
SELECT cli.nombre, cli.apellido, pdad.id, pdad.direccion, MIN(pago.fecha_hora_pago) primer_pago,
MAX(pago.fecha_hora_pago) ultimo_pago, COUNT(*) cant_pagos
FROM solicitud_contrato sol
INNER JOIN persona cli ON sol.id_cliente = cli.id
INNER JOIN propiedad pdad ON pdad.id = sol.id_propiedad
INNER JOIN pago ON pago.id_solicitud = sol.id
WHERE sol.estado = "en alquiler"
GROUP BY cli.nombre, cli.apellido, pdad.id, pdad.direccion
