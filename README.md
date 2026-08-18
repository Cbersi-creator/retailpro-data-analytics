# RetailPro Data Analytics
### Proyecto Integrador — Curso Data Analytics | Coderhouse
**Alumno:** Constante Bersi  
**Año:** 2025  
**Herramientas:** SQL Server · Power BI Desktop · Power Query · DAX · GitHub

---

## Descripción del proyecto

RetailPro es una empresa distribuidora de tecnología que necesitaba transformar sus datos de ventas dispersos en un sistema de análisis completo. Este proyecto construye ese sistema de principio a fin: desde la base de datos relacional hasta el dashboard ejecutivo, pasando por la limpieza de datos y el modelado analítico.

**Pregunta estratégica que responde el proyecto:**
> ¿Qué factores explican la diferencia de rentabilidad entre regiones y categorías de producto, y qué palancas comerciales debería activar RetailPro para mejorar su margen neto?

---

## Estructura del repositorio

```
retailpro-data-analytics/
├── README.md
├── M3/
│   └── Ventas_Tech_DB.sql          → DDL + DML: crea y carga la base de datos
├── M4/
│   └── m4_consultas_negocio.sql    → Consultas de agregación (KPIs de negocio)
├── M5/
│   └── m5_consultas_joins.sql      → Consultas con JOINs y UNION
├── M6/
│   └── Pipeline_ETL_Bersi_Constante.pbix  → Pipeline ETL en Power BI
├── M7/
│   └── M8_Boceto_Dashboard_Bersi_Constante.jpg  → Boceto del dashboard
├── M8/
│   └── Bersi_Constante_Checkpoint2.pbix   → Modelo DAX con relaciones y medidas
└── M9/
    └── M9_IA_Proyecto_Bersi_Constante.pdf → Documentación con IA
```

---

## Base de datos — Ventas_Tech_DB

Modelo relacional normalizado hasta 3NF con 4 tablas:

| Tabla | Descripción | Filas |
|---|---|---|
| `categorias` | Categorías de productos | 4 |
| `clientes` | Clientes registrados | 5 |
| `productos` | Catálogo de productos | 6 |
| `ventas` | Transacciones (tabla de hechos) | 10 |

### Cómo ejecutar el script SQL

1. Abrí **SQL Server Management Studio**
2. Conectate a tu instancia local
3. Abrí el archivo `M3/Ventas_Tech_DB.sql`
4. Ejecutá con **F5**

El script crea automáticamente la base de datos `Ventas_Tech_DB`, las tablas con sus claves primarias y foráneas, y carga todos los datos iniciales. Incluye `DROP TABLE IF EXISTS` al inicio para ser repetible.

---

## Consultas SQL (M4 y M5)

### M4 — Métricas de negocio
- Resumen ejecutivo mensual (ventas, pedidos, ticket promedio)
- Ranking Top 5 productos por facturación
- Clientes recurrentes (HAVING COUNT > 1)
- Meses sobre/bajo el promedio (CASE WHEN + CTE)

### M5 — JOINs y UNION
- Vista base del proyecto (INNER JOIN de 4 tablas)
- Clientes sin ventas (LEFT JOIN + IS NULL)
- Productos sin ventas (LEFT JOIN + IS NULL)
- Consolidado por canal (UNION ALL)

---

## Pipeline ETL — Power BI (M6)

Conexión directa al archivo Excel fuente con transformaciones en Power Query:

| Tabla | Transformaciones aplicadas |
|---|---|
| `Dim_Clientes` | Eliminación duplicados · Nulos reemplazados · Tipado |
| `Dim_Productos` | Eliminación duplicados · Precio nulo → 0 · Tipado |
| `Dim_Categorias` | Tipado básico (tabla limpia) |
| `Fact_Ventas` | Tipado · Merge con Dim_Productos |

---

## Modelo analítico DAX (M8)

### Relaciones del modelo (esquema en estrella)
```
Dim_Clientes    ──(1:N)──→ Fact_Ventas
Dim_Productos   ──(1:N)──→ Fact_Ventas
Dim_Categorias  ──(1:N)──→ Dim_Productos
Dim_Fechas      ──(1:N)──→ Fact_Ventas
```

### Medidas DAX implementadas

```dax
Total Ventas        = SUM(Fact_Ventas[total_venta])
Ventas Online       = CALCULATE([Total Ventas], Fact_Ventas[canal] = "Online")
Ventas YTD          = TOTALYTD([Total Ventas], Dim_Fechas[Date])
Ventas LY           = CALCULATE([Total Ventas], SAMEPERIODLASTYEAR(Dim_Fechas[Date]))
% Crecimiento Anual = VAR VentasActual = [Total Ventas]
                      VAR VentasAnterior = [Ventas LY]
                      RETURN DIVIDE(VentasActual - VentasAnterior, VentasAnterior)
```

---

## KPIs del dashboard

| KPI | Descripción | Fórmula conceptual |
|---|---|---|
| Total Ventas | Monto total facturado | SUM(total_venta) |
| Margen Bruto | Rentabilidad sobre ventas | (Ventas - Costo) / Ventas |
| Ticket Promedio | Valor medio por transacción | SUM / COUNT(id_venta) |
| Clientes Activos | Clientes únicos con compras | DISTINCTCOUNT(id_cliente) |

---

## Contacto

**Constante Bersi**  
Curso Data Analytics — Coderhouse 2025  
[GitHub](https://github.com/Cbersi-creator/retailpro-data-analytics)
