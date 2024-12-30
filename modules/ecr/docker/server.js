const express = require('express');
const mysql = require('mysql2/promise');
const app = express();
app.use(express.json());

const dbConfig = {
  host: 'localhost.localstack.cloud',
  user: 'admin',
  password: '4Ernfb7E1',
  database: 'test',
  port: 4510
};

let connection;

async function getConnection() {
  if (!connection) {
    connection = await mysql.createConnection(dbConfig);
  }
  return connection;
}

app.use(express.static('public'));

app.get('/api/health', async (req, res) => {
  try {
    const conn = await getConnection();
    await conn.ping();
    res.json({ database: 'connected' });
  } catch (err) {
    res.json({ database: 'disconnected', error: err.message });
  }
});

app.get('/api/messages', async (req, res) => {
  try {
    const conn = await getConnection();
    const [rows] = await conn.execute('SELECT * FROM messages ORDER BY created_at DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/messages', async (req, res) => {
  try {
    const conn = await getConnection();
    const result = await conn.execute(
      'INSERT INTO messages (message) VALUES (?)',
      [req.body.message]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// メインページのルート
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
  getConnection().catch(err => {
    console.error('Initial database connection failed:', err);
  });
});