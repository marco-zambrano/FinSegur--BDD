-- Habilitar extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear usuarios para replicación y API
-- Usuario para escritura (usado por el backend y la replicación desde pg-trans)
CREATE USER replica_trans WITH PASSWORD 'transpass';

-- Usuario para lectura (usado por el backend y la replicación hacia pg-readonly)
CREATE USER replica_read WITH PASSWORD 'readpass';