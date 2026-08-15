-- ============================================================
--  PROYECTO RETAILPRO — Ventas_Tech_DB
--  Módulo 4 — Pre-entrega: Consultas SQL de negocio
--  Título  : Extrayendo métricas clave con SQL
--  Alumno  : Constante Bersi
--  Curso   : Data Analytics — Coderhouse
--  Motor   : SQL Server
--  Base    : Ventas_Tech_DB (creada en M3)
-- ============================================================

USE Ventas_Tech_DB;
GO


-- ============================================================
-- CONSULTA 1 — Resumen ejecutivo mensual
-- Responde: ¿Cuánto facturamos por mes, cuántos pedidos
-- se realizaron y cuál fue el ticket promedio?
-- ============================================================

SELECT
    MONTH(fecha_venta)                          AS mes,
    SUM(cantidad * precio_unitario)             AS total_facturado,
    COUNT(*)                                    AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)             AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- Nota PostgreSQL: reemplazar MONTH(fecha_venta)
-- por EXTRACT(MONTH FROM fecha_venta)


-- ============================================================
-- CONSULTA 2 — Ranking de productos (Top 5)
-- Responde: ¿Qué productos generan mayor facturación?
-- Ordenados de mayor a menor por total generado.
-- ============================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad)                               AS unidades_vendidas,
    SUM(cantidad * precio_unitario)             AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- Nota PostgreSQL: reemplazar TOP 5 por LIMIT 5 al final


-- ============================================================
-- CONSULTA 3 — Clientes recurrentes
-- Responde: ¿Qué clientes realizaron más de un pedido?
-- Muestra su cantidad de pedidos y total gastado.
-- ============================================================

SELECT
    id_cliente,
    COUNT(*)                                    AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)             AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- ============================================================
-- CONSULTA 4 — Meses por encima / por debajo del promedio
-- Responde: ¿En qué meses se superó el promedio mensual?
-- Usa un CTE para calcular el promedio general primero,
-- luego lo compara con cada mes usando CASE WHEN.
-- ============================================================

WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta)                      AS mes,
        SUM(cantidad * precio_unitario)         AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
),
promedio_general AS (
    SELECT AVG(total_facturado) AS promedio_mensual
    FROM facturacion_mensual
)
SELECT
    fm.mes,
    fm.total_facturado,
    pg.promedio_mensual,
    CASE
        WHEN fm.total_facturado >= pg.promedio_mensual
            THEN 'Por encima'
        ELSE
            'Por debajo'
    END                                         AS rendimiento_vs_promedio
FROM facturacion_mensual fm
CROSS JOIN promedio_general pg
ORDER BY fm.mes;

-- Nota PostgreSQL: reemplazar MONTH(fecha_venta)
-- por EXTRACT(MONTH FROM fecha_venta)


-- ============================================================
-- BLOQUE DE CIERRE — Hallazgos del análisis
-- ============================================================

-- HALLAZGO 1 — Concentración en un solo producto
-- El producto 1 (Laptop Pro 15) concentra el 55.9% de la
-- facturación total ($3.600 de $6.444), a pesar de ser el
-- artículo con menor volumen de unidades vendidas (3 unidades).
-- Esto indica que el margen por unidad es el motor principal
-- de los ingresos, no el volumen.
-- Acción sugerida: proteger el stock de Laptop Pro 15 y
-- evaluar estrategias de upselling hacia productos de alto valor.

-- HALLAZGO 2 — Base de clientes 100% recurrente
-- Los 5 clientes registrados realizaron exactamente 2 pedidos
-- cada uno, lo que indica una tasa de retención del 100% en
-- el período analizado. Sin embargo, la dispersión en gasto
-- es alta: el cliente 1 gastó $2.640 mientras el cliente 4
-- gastó solo $510. Existe una oportunidad de aumentar el valor
-- por cliente en los segmentos de menor gasto.

-- HALLAZGO 3 — Período de análisis limitado a un solo mes
-- Todos los registros corresponden a marzo de 2024, lo que
-- impide comparar tendencias entre meses. Para la consulta 4
-- (rendimiento vs. promedio), el mes de marzo queda
-- automáticamente "por encima o igual" al promedio general
-- porque es el único mes disponible. Se recomienda cargar
-- datos de al menos 3 meses para obtener análisis de
-- estacionalidad significativos antes de conectar Power BI.

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
