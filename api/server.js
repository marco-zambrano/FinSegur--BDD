// finsegur-project/api/server.js
require("dotenv").config();
const express = require("express");
const { Pool } = require("pg");

const app = express();
app.use(express.json());

// Pool de conexión para ESCRITURAS (se conecta a pg-master)
const writePool = new Pool({
    host: process.env.WRITE_DB_HOST,
    port: process.env.WRITE_DB_PORT,
    user: process.env.WRITE_DB_USER,
    password: process.env.WRITE_DB_PASSWORD,
    database: process.env.WRITE_DB_DATABASE,
});

// Pool de conexión para LECTURAS (se conecta a pg-readonly)
const readPool = new Pool({
    host: process.env.READ_DB_HOST,
    port: process.env.READ_DB_PORT,
    user: process.env.READ_DB_USER,
    password: process.env.READ_DB_PASSWORD,
    database: process.env.READ_DB_DATABASE,
});

// Ruta de escritura: POST /movimientos
app.post("/movimientos", async (req, res) => {
    console.log(
        "INFO: Recibida petición de escritura en /movimientos. Usando pg-master."
    );
    const { cuenta_id, tipo_movimiento, monto } = req.body;
    if (!cuenta_id || !tipo_movimiento || !monto) {
        return res.status(400).json({ error: "Faltan datos requeridos." });
    }

    try {
        const result = await writePool.query(
        "INSERT INTO movimientos (cuenta_id, tipo_movimiento, monto) VALUES ($1, $2, $3) RETURNING *",
        [cuenta_id, tipo_movimiento, monto]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error al escribir en pg-master:", error);
        res.status(500).json({ error: "Error interno del servidor." });
    }
});

// Ruta de lectura: GET /clientes/:id
app.get("/clientes/:id", async (req, res) => {
    console.log(
        "INFO: Recibida petición de lectura en /clientes. Usando pg-readonly."
    );
    const { id } = req.params;
    try {
        const result = await readPool.query(
        "SELECT * FROM clientes WHERE id = $1",
        [id]
        );
        if (result.rows.length === 0) {
        return res.status(404).json({ error: "Cliente no encontrado." });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error al leer de pg-readonly:", error);
        res.status(500).json({ error: "Error interno del servidor." });
    }
});

// Ruta de lectura: GET /auditorias
app.get("/auditorias", async (req, res) => {
    console.log(
        "INFO: Recibida petición de lectura en /auditorias. Usando pg-readonly."
    );
    try {
        const result = await readPool.query(
        "SELECT * FROM auditorias ORDER BY fecha_accion DESC"
        );
        res.json(result.rows);
    } catch (error) {
        console.error("Error al leer de pg-readonly:", error);
        res.status(500).json({ error: "Error interno del servidor." });
    }
});

const PORT = process.env.API_PORT || 3000;
app.listen(PORT, () => {
    console.log(`API de FinSegur escuchando en el puerto ${PORT}`);
    console.log(`- Escrituras dirigidas a: ${process.env.WRITE_DB_HOST}`);
    console.log(`- Lecturas dirigidas a: ${process.env.READ_DB_HOST}`);
});
