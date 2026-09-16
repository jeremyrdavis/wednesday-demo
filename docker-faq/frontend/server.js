const express = require('express');
const app = express();

const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8000';

app.use(express.static('public'));

app.get('/api/*', async (req, res) => {
  try {
    const upstream = await fetch(`${BACKEND_URL}${req.url}`);
    const data = await upstream.json();
    res.status(upstream.status).json(data);
  } catch (err) {
    res.status(502).json({ error: 'backend unavailable' });
  }
});

app.listen(3000, () => console.log('Frontend listening on :3000'));
