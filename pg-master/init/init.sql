-- Habilitar extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de Sucursales
CREATE TABLE sucursales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255)
);

-- Tabla de Clientes
CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Cuentas
CREATE TABLE cuentas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID NOT NULL REFERENCES clientes(id),
    sucursal_id UUID NOT NULL REFERENCES sucursales(id),
    numero_cuenta VARCHAR(50) UNIQUE NOT NULL,
    saldo NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    fecha_apertura TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Movimientos
CREATE TABLE movimientos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cuenta_id UUID NOT NULL REFERENCES cuentas(id),
    tipo_movimiento VARCHAR(20) NOT NULL, -- 'DEPOSITO', 'RETIRO', 'TRANSFERENCIA'
    monto NUMERIC(15, 2) NOT NULL,
    fecha_movimiento TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Auditorías
CREATE TABLE auditorias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tabla_afectada VARCHAR(50) NOT NULL,
    registro_id UUID,
    accion VARCHAR(50) NOT NULL,
    detalles TEXT,
    usuario_accion VARCHAR(100),
    fecha_accion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Crear usuarios para replicación y API
-- Usuario para escritura (usado por el backend y la replicación desde pg-trans)
CREATE USER replica_trans WITH PASSWORD 'transpass';
GRANT CONNECT ON DATABASE finanzas TO replica_trans;
GRANT USAGE ON SCHEMA public TO replica_trans;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO replica_trans;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO replica_trans;

-- Usuario para lectura (usado por el backend y la replicación hacia pg-readonly)
CREATE USER replica_read WITH PASSWORD 'readpass';
GRANT CONNECT ON DATABASE finanzas TO replica_read;
GRANT USAGE ON SCHEMA public TO replica_read;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replica_read;