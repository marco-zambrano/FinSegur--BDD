El contexto del problema es el siguiente:
La empresa FinSegur, dedicada a servicios financieros digitales, está diseñando una
arquitectura robusta de base de datos distribuida para garantizar:
• Alta disponibilidad
• Balanceo de carga de lectura
• Consistencia entre nodos
• Seguridad en el acceso y replicación.

Claramente todo esto tiene requisitos de seguridad, que van a ser los siguientes:


1. Conexiones únicamente entre contenedores internos en red Docker privada.
2. Restricción de IPs en pg_hba.conf para cada nodo.
3. Usuarios diferenciados:
o replica_trans para escritura
o replica_read para lectura
4. No exposición de puertos PostgreSQL al exterior.
Lo que debes realizar:

Parte 1: Arquitectura y Modelado


1. Crear un entorno completo con docker-compose para:
o 3 nodos PostgreSQL (pg-master, pg-trans, pg-readonly)
o 1 nodo symmetricds
o 1 servicio backend (Node.js, Python, Java, etc.)
2. Modelar la base finanzas con al menos estas entidades:
o clientes, cuentas, movimientos, sucursales, auditorias
o Uso de UUIDs como identificadores
o Relaciones correctas entre entidades
Parte 2: Replicación


1. Configurar SymmetricDS para:
o Replicación bidireccional entre pg-master y pg-trans
o Replicación unidireccional de pg-master hacia pg-readonly
2. Configurar sym_trigger, sym_router, sym_trigger_router, etc., para replicar las tablas: clientes (Master -> Trans; Master -> Readonly), cuentas (Master -> <- Trans; Master -> Readonly), movimientos (Master -> <- Trans), auditorias (Trans -> Master -> Readonly)
Parte 3: Seguridad


1. Configurar reglas en pg_hba.conf para permitir conexiones solo desde IPs
internas.
2. Montar postgresql.conf para habilitar replicación lógica.
3. Usar usuarios con permisos mínimos por tipo de replicación.
4. Validar que desde el host no se puede conectar directamente a las BDs.
Parte 4: Validaciones
• Insertar desde pg-master y ver reflejo en pg-trans y pg-readonly.
• Insertar desde pg-trans y verificar sincronización con pg-master.
• Lectura exitosa desde pg-readonly, escritura bloqueada.
• Validar consistencia entre nodos con datos cruzados.

Parte 5: Desarrollo de una API
Objetivo: Desarrollar una pequeña API REST con rutas separadas para operaciones de
escritura y lectura.
Requisitos:


1. El backend debe utilizar dos conexiones a PostgreSQL:
o Una conexión a pg-master para operaciones de escritura (POST, PUT, etc.)
o Otra conexión a pg-readonly para operaciones de lectura (GET)
2. Implementar al menos las siguientes rutas:
o POST /movimientos → crea movimiento en pg-master
o GET /clientes/:id → consulta información de cliente desde pg-readonly
o GET /auditorias → muestra auditorías replicadas en pg-readonly
3. Proteger el código de conexión mediante variables de entorno (.env)
4. Opcional: Agregar logs o métricas para validar de qué nodo proviene cada
respuesta.