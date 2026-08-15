-- ============================================================
--  PROYECTO RETAILPRO — Ventas_Tech_DB
--  Módulo 3 — Pre-entrega: Script SQL de Ingeniería de Datos
--  Alumno : Constante Bersi
--  Curso  : Data Analytics — Coderhouse
--  Motor  : PostgreSQL
-- ============================================================


-- ============================================================
-- SECCIÓN 0: CREACIÓN DE LA BASE DE DATOS
-- ============================================================
-- Ejecutar en psql como superusuario antes de correr el resto:
--   CREATE DATABASE Ventas_Tech_DB;
--   \c Ventas_Tech_DB


-- ============================================================
-- SECCIÓN 1: DROP TABLES
-- Se eliminan en orden inverso de dependencias para no violar
-- las FOREIGN KEYS (primero las que dependen, al final las
-- tablas referenciadas).
-- ============================================================

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;


-- ============================================================
-- SECCIÓN 2: DDL — DEFINICIÓN DEL ESQUEMA (CREATE TABLES)
-- Orden: primero tablas sin dependencias (categorias, clientes),
-- luego productos (depende de categorias),
-- finalmente ventas (depende de clientes y productos).
-- ============================================================

-- ----------------------------------------------------------
-- Tabla: categorias
-- Permite cumplir 3NF: el nombre de categoría vive una sola
-- vez y productos lo referencia mediante FK.
-- ----------------------------------------------------------
CREATE TABLE categorias (
    id_categoria     INT            PRIMARY KEY,
    nombre_categoria VARCHAR(50)    NOT NULL,
    descripcion      VARCHAR(200)
);

-- ----------------------------------------------------------
-- Tabla: clientes
-- Registra a los compradores con datos de contacto.
-- Email con restricción UNIQUE: no puede haber dos clientes
-- con el mismo correo electrónico.
-- ----------------------------------------------------------
CREATE TABLE clientes (
    id_cliente      INT            PRIMARY KEY,
    nombre          VARCHAR(100)   NOT NULL,
    email           VARCHAR(100)   UNIQUE,
    ciudad          VARCHAR(50),
    fecha_registro  DATE           NOT NULL
);

-- ----------------------------------------------------------
-- Tabla: productos
-- Catálogo de artículos disponibles para la venta.
-- id_categoria referencia a la tabla categorias (FK).
-- stock con DEFAULT 0: si no se indica, empieza en cero.
-- activo con DEFAULT 1 (1=activo, 0=dado de baja).
-- ----------------------------------------------------------
CREATE TABLE productos (
    id_producto      INT             PRIMARY KEY,
    nombre_producto  VARCHAR(100)    NOT NULL,
    id_categoria     INT             NOT NULL,
    precio           DECIMAL(10,2)   NOT NULL,
    stock            INT             DEFAULT 0,
    activo           SMALLINT        DEFAULT 1,
    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- ----------------------------------------------------------
-- Tabla: ventas (tabla de hechos central)
-- Registra cada transacción de venta.
-- Conecta clientes y productos mediante FK.
-- precio_unitario se guarda en la venta para preservar el
-- precio histórico aunque el producto cambie de precio.
-- ----------------------------------------------------------
CREATE TABLE ventas (
    id_venta         INT             PRIMARY KEY,
    id_cliente       INT             NOT NULL,
    id_producto      INT             NOT NULL,
    cantidad         INT             NOT NULL,
    precio_unitario  DECIMAL(10,2)   NOT NULL,
    fecha_venta      DATE            NOT NULL,
    CONSTRAINT fk_venta_cliente
        FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
    CONSTRAINT fk_venta_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


-- ============================================================
-- SECCIÓN 3: DML — CARGA INICIAL DE DATOS (INSERT INTO)
-- Mismo orden lógico: categorias → clientes → productos → ventas
-- ============================================================

-- ----------------------------------------------------------
-- categorias: 4 registros
-- ----------------------------------------------------------
INSERT INTO categorias VALUES (1, 'Computación',    'Laptops, PCs y monitores');
INSERT INTO categorias VALUES (2, 'Accesorios',     'Periféricos y complementos');
INSERT INTO categorias VALUES (3, 'Audio',           'Auriculares y parlantes');
INSERT INTO categorias VALUES (4, 'Almacenamiento', 'Discos y memorias');

-- ----------------------------------------------------------
-- clientes: 5 registros
-- ----------------------------------------------------------
INSERT INTO clientes VALUES (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05');
INSERT INTO clientes VALUES (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10');
INSERT INTO clientes VALUES (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01');
INSERT INTO clientes VALUES (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15');
INSERT INTO clientes VALUES (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

-- ----------------------------------------------------------
-- productos: 6 registros distribuidos en las 4 categorías
-- ----------------------------------------------------------
INSERT INTO productos VALUES (1, 'Laptop Pro 15',      1, 1200.00, 15, 1);
INSERT INTO productos VALUES (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1);
INSERT INTO productos VALUES (3, 'Monitor 4K 27"',     1,  450.00, 12, 1);
INSERT INTO productos VALUES (4, 'Auriculares BT Pro', 3,  120.00, 35, 1);
INSERT INTO productos VALUES (5, 'SSD Externo 1TB',    4,  130.00, 18, 1);
INSERT INTO productos VALUES (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

-- ----------------------------------------------------------
-- ventas: 10 transacciones
-- Formato: (id_venta, id_cliente, id_producto, cantidad,
--           precio_unitario, fecha_venta)
-- ----------------------------------------------------------
INSERT INTO ventas VALUES (1,  1, 1, 2, 1200.00, '2024-03-05');
INSERT INTO ventas VALUES (2,  2, 2, 5,   28.00, '2024-03-06');
INSERT INTO ventas VALUES (3,  3, 3, 1,  450.00, '2024-03-07');
INSERT INTO ventas VALUES (4,  1, 4, 2,  120.00, '2024-03-08');
INSERT INTO ventas VALUES (5,  4, 5, 3,  130.00, '2024-03-10');
INSERT INTO ventas VALUES (6,  2, 6, 4,   95.00, '2024-03-11');
INSERT INTO ventas VALUES (7,  5, 1, 1, 1200.00, '2024-03-12');
INSERT INTO ventas VALUES (8,  3, 2, 8,   28.00, '2024-03-13');
INSERT INTO ventas VALUES (9,  4, 4, 1,  120.00, '2024-03-14');
INSERT INTO ventas VALUES (10, 5, 3, 2,  450.00, '2024-03-15');


-- ============================================================
-- SECCIÓN 4: VALIDACIÓN — CONSULTAS DE VERIFICACIÓN
-- Ejecutar después de correr el script para confirmar que
-- los datos se cargaron correctamente.
-- ============================================================

-- Verificar carga de cada tabla
SELECT * FROM categorias;      -- debe retornar 4 filas
SELECT * FROM clientes;        -- debe retornar 5 filas
SELECT * FROM productos;       -- debe retornar 6 filas
SELECT * FROM ventas;          -- debe retornar 10 filas

-- Verificar totales por tabla
SELECT 'categorias' AS tabla, COUNT(*) AS registros FROM categorias
UNION ALL
SELECT 'clientes',   COUNT(*) FROM clientes
UNION ALL
SELECT 'productos',  COUNT(*) FROM productos
UNION ALL
SELECT 'ventas',     COUNT(*) FROM ventas;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
