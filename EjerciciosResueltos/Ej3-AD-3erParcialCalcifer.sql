/*CH-AD03 – Normalizar la situación de las propiedades
Enunciado
Actualmente la situación de la propiedad (propiedad.situacion) se almacena como texto 
(por ejemplo: “a verificar”, “en oferta”, “señada”, “alquilada”).
Se pide:

1. Crear una entidad situacion_propiedad con un id autoincremental y una descripción.
2. Migrar las situaciones actualmente registradas en propiedad.situacion a la nueva tabla y agregar 
   en propiedad la columna id_situacion como clave foránea.
3. Cargar en id_situacion el valor correspondiente y eliminar la columna antigua situacion.
4. Realizar la migración dentro de una transacción.
*/
CREATE TABLE `inmobiliaria_calciferhowl`.`situacion_propiedad` (
`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`descripcion` VARCHAR(45) NULL,
PRIMARY KEY (`id`));


ALTER TABLE `inmobiliaria_calciferhowl`.`propiedad`
ADD COLUMN `id_situacion` INT UNSIGNED NULL AFTER `situacion`,
ADD INDEX `fk_propiedad_situacion_propiedad_idx` (`id_situacion` ASC) VISIBLE;
;
ALTER TABLE `inmobiliaria_calciferhowl`.`propiedad`
ADD CONSTRAINT `fk_propiedad_situacion_propiedad`
FOREIGN KEY (`id_situacion`)
REFERENCES `inmobiliaria_calciferhowl`.`situacion_propiedad` (`id`)
ON DELETE NO ACTION
ON UPDATE NO ACTION;



BEGIN;
INSERT INTO situacion_propiedad (descripcion)
SELECT DISTINCT situacion FROM propiedad;

COMMIT;
ALTER TABLE `inmobiliaria_calciferhowl`.`propiedad`
DROP COLUMN `situacion`;