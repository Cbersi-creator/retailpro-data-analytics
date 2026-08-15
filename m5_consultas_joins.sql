-- ============================================================
--  PROYECTO RETAILPRO — Ventas_Tech_DB
--  Módulo 5 — Pre-entrega: Consultas con JOINs
--  Título  : Cruzando tablas para enriquecer el análisis
--  Alumno  : Constante Bersi
--  Curso   : Data Analytics — Coderhouse
--  Motor   : SQL Server
-- ============================================================
-- NOTA: La tabla ventas de M3 no incluía la columna "canal"
-- ni existe la tabla "territorios" en el esquema de M3.
-- Este script agrega la columna "canal" a ventas y usa la
-- columna "ciudad" de clientes como proxy de región,
-- manteniendo consistencia con el modelo definido en M2.
-- ============================================================

USE Ventas_Tech_DB;
GO


-- ============================================================
-- PREPARACIÓN: Agregar columna "canal" a ventas si no existe
-- Se hace una sola vez; si ya existe, no genera error.
-- ============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('ventas') AND name = 'canal'
)
    ALTER TABLE ventas ADD canal VARCHAR(50);
GO

-- Cargar valores de canal en las 10 ventas existentes
UPDATE ventas SET canal = 'Online'     WHERE id_venta IN (1, 3, 5, 7, 9);
UPDATE ventas SET canal = 'Presencial' WHERE id_venta IN (2, 4, 6, 8, 10);
GO


-- ============================================================
-- CONSULTA 1 — Vista base del proyecto (INNER JOIN)
-- Combina ventas, clientes, productos y categorias en una
-- sola fila. Esta consulta es la fuente de datos principal
-- que se conectará a Power BI en M6.
-- Nota: se usa "ciudad" como proxy de región dado que la
-- tabla "territorios" no forma parte del esquema de M3.
-- ============================================================

SELECT
    v.fecha_venta                               AS fecha,
    c.nombre                                    AS nombre_cliente,
    c.ciudad                                    AS region,
    p.nombre_producto                           AS producto,
    cat.nombre_categoria                        AS categoria,
    v.cantidad                                  AS cantidad,
    v.precio_unitario                           AS precio_unitario,
    v.cantidad * v.precio_unitario              AS total_venta,
    v.canal                                     AS canal
FROM ventas v
INNER JOIN clientes  c   ON v.id_cliente  = c.id_cliente
INNER JOIN productos p   ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;


-- ============================================================
-- CONSULTA 2 — Clientes sin ventas (LEFT JOIN)
-- Identifica clientes registrados que aún no realizaron
-- ninguna compra. El LEFT JOIN trae todos los clientes;
-- el WHERE IS NULL filtra los que no tienen venta asociada.
-- ============================================================

SELECT
    c.id_cliente,
    c.nombre                                    AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro;

-- Resultado esperado: 0 filas.
-- Todos los clientes registrados en M3 tienen al menos
-- una compra. Para ver este caso funcionando, se podría
-- insertar un cliente sin ventas:
-- INSERT INTO clientes VALUES (6, 'Test Sin Compra',
--   'test@mail.com', 'Salta', '2024-04-01');


-- ============================================================
-- CONSULTA 3 — Productos sin ventas (LEFT JOIN)
-- Identifica productos del catálogo sin ninguna venta
-- registrada. Útil para detectar stock sin movimiento.
-- ============================================================

SELECT
    p.id_producto,
    p.nombre_producto                           AS producto,
    cat.nombre_categoria                        AS categoria,
    p.precio
FROM productos p
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v       ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.precio DESC;

-- Resultado esperado: 0 filas.
-- Todos los productos del catálogo cargado en M3 tienen
-- al menos una transacción registrada. En un catálogo real
-- con cientos de productos es esperable encontrar artículos
-- sin movimiento, que representan stock inmovilizado.


-- ============================================================
-- CONSULTA 4 — Consolidado por canal (UNION ALL)
-- Combina con UNION ALL las ventas Online y Presencial,
-- identificando el origen de cada fila. Luego agrupa por
-- canal para obtener el total facturado por cada uno.
-- ============================================================

-- Paso A: vista detallada con UNION ALL (una fila por venta)
SELECT
    id_venta,
    fecha_venta,
    cantidad * precio_unitario                  AS total_venta,
    'Online'                                    AS origen
FROM ventas
WHERE canal = 'Online'

UNION ALL

SELECT
    id_venta,
    fecha_venta,
    cantidad * precio_unitario,
    'Presencial'
FROM ventas
WHERE canal = 'Presencial'

ORDER BY fecha_venta;
GO

-- Paso B: resumen agregado por canal
SELECT
    canal                                       AS canal,
    COUNT(*)                                    AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)             AS total_facturado,
    AVG(cantidad * precio_unitario)             AS ticket_promedio
FROM ventas
GROUP BY canal
ORDER BY total_facturado DESC;


-- ============================================================
-- BLOQUE DE CIERRE — Hallazgos del análisis con JOINs
-- ============================================================

-- HALLAZGO 1 — El canal Online concentra el 70.8% de la
-- facturación total ($4.560 de $6.444), duplicando en
-- valor al canal Presencial ($1.884). Sin embargo, ambos
-- canales tienen la misma cantidad de pedidos (5 cada uno),
-- lo que indica que el ticket promedio Online es
-- significativamente más alto. Esto sugiere que los clientes
-- online tienden a comprar productos de mayor valor
-- (como laptops y monitores), mientras el canal presencial
-- concentra accesorios y periféricos de menor precio.

-- HALLAZGO 2 — No se detectaron clientes sin compras ni
-- productos sin ventas en el período analizado. Si bien
-- esto es positivo en términos operativos, también refleja
-- que el dataset de M3 es pequeño (5 clientes, 6 productos).
-- En un escenario real con un catálogo amplio, las consultas
-- 2 y 3 serían críticas para identificar clientes inactivos
-- para campañas de reactivación y productos con stock
-- inmovilizado para decisiones de descuento o discontinuación.

-- HALLAZGO 3 — La vista base de la Consulta 1 cruza las
-- 4 tablas del modelo en una sola consulta, generando
-- 10 filas enriquecidas con nombre de cliente, producto y
-- categoría. Esta vista es la materia prima directa del
-- dashboard de Power BI: en M6 se conectará Power BI a
-- esta base de datos y se usará esta consulta como origen
-- del modelo analítico. El campo "ciudad" actúa como proxy
-- de región hasta que se implemente la tabla territorios.

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
