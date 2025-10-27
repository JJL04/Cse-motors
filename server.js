const path = require('path');
const fs = require('fs');
const express = require('express');
const expressLayouts = require('express-ejs-layouts');

const app = express();
const PORT = process.env.PORT || 3000;

// view engine and layouts
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(expressLayouts);
app.set('layout', 'layouts/layout');

// static
app.use(express.static(path.join(__dirname, 'public')));

// body parsing
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

// Simple in-repo JSON data store
const DATA_FILE = path.join(__dirname, 'data', 'entries.json');
function readData(){
  try{
    return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8')) || [];
  }catch(e){
    return [];
  }
}
function writeData(arr){
  fs.writeFileSync(DATA_FILE, JSON.stringify(arr, null, 2));
}

// Ensure data directory and file exist (helps in read-only or fresh deploy environments)
try {
  const dataDir = path.join(__dirname, 'data');
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
    console.log('Created data directory');
  }
  if (!fs.existsSync(DATA_FILE)) {
    fs.writeFileSync(DATA_FILE, JSON.stringify([]));
    console.log('Created entries.json');
  }
} catch (err) {
  console.error('Failed to ensure data files:', err);
}

// routes
// simple health check to verify the server is up without rendering templates
app.get('/_health', (req, res) => res.status(200).send('OK'));

app.get('/', (req, res) => {
  res.render('index', { title: 'CSE Motors' });
});

app.post('/inquiry', (req, res) => {
  const { name, email, message } = req.body;
  const errors = [];
  if(!name || name.trim().length < 2) errors.push('Name must be at least 2 characters');
  if(!email || !/^\S+@\S+\.\S+$/.test(email)) errors.push('A valid email is required');
  if(!message || message.trim().length < 5) errors.push('Message must be at least 5 characters');

  if(errors.length){
    return res.status(400).render('index', { title: 'CSE Motors', errors, form: { name, email, message } });
  }

  const entries = readData();
  entries.push({ id: Date.now(), name, email, message, createdAt: new Date().toISOString() });
  try{
    writeData(entries);
  }catch(e){
    console.error('Failed to write data', e);
    // render an error page but include the error message in console for debugging
    return res.status(500).render('index', { title: 'CSE Motors', errors: ['Server error saving your inquiry'], form: { name, email, message } });
  }

  res.render('index', { title: 'CSE Motors', success: 'Thanks! Your inquiry has been received.' });
});

// start server if not being required (for tests)
if (!module.parent) {
  app.listen(PORT, () => console.log(`Server listening on http://localhost:${PORT}`));
}

module.exports = app;

// error handler (will show stack in response for debugging -- remove or restrict in production)
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err && err.stack ? err.stack : err);
  res.status(500).send('<pre>' + (err && err.stack ? err.stack : String(err)) + '</pre>');
});
