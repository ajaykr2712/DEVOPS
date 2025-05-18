/**
 * REST API Server Implementation
 * A simple Express.js server implementing RESTful endpoints
 */

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const swaggerUi = require('swagger-ui-express');
const swaggerDocument = require('./swagger.json');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// Simple in-memory database
let users = [
  { id: 1, name: 'John Doe', email: 'john@example.com', role: 'admin' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
];

// Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Forbidden' });
    req.user = user;
    next();
  });
};

// Routes

// Health check endpoint
app.get('/health/live', (req, res) => {
  res.status(200).json({ status: 'alive' });
});

app.get('/health/ready', (req, res) => {
  res.status(200).json({ status: 'ready' });
});

// Authentication
app.post('/login', (req, res) => {
  const { email, password } = req.body;
  
  // In a real app, you would validate credentials against a database
  const user = users.find(u => u.email === email);
  
  if (!user) return res.status(400).json({ error: 'Invalid credentials' });
  
  // Generate JWT token
  const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '1h' });
  
  res.json({ token });
});

// User endpoints
app.get('/users', authenticateToken, (req, res) => {
  // Pagination implementation
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  
  const results = {};
  
  if (endIndex < users.length) {
    results.next = {
      page: page + 1,
      limit: limit
    };
  }
  
  if (startIndex > 0) {
    results.previous = {
      page: page - 1,
      limit: limit
    };
  }
  
  results.users = users.slice(startIndex, endIndex);
  results.total = users.length;
  
  res.json(results);
});

app.get('/users/:id', authenticateToken, (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  
  if (!user) return res.status(404).json({ error: 'User not found' });
  
  res.json(user);
});

app.post('/users', authenticateToken, (req, res) => {
  // Check if user has admin role
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden: Admin access required' });
  }
  
  const { name, email, role } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({ error: 'Name and email are required' });
  }
  
  const newUser = {
    id: users.length + 1,
    name,
    email,
    role: role || 'user'
  };
  
  users.push(newUser);
  
  res.status(201).json(newUser);
});

app.put('/users/:id', authenticateToken, (req, res) => {
  // Check if user has admin role or is updating their own record
  if (req.user.role !== 'admin' && req.user.id !== parseInt(req.params.id)) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  const userIndex = users.findIndex(u => u.id === parseInt(req.params.id));
  
  if (userIndex === -1) return res.status(404).json({ error: 'User not found' });
  
  const { name, email, role } = req.body;
  
  // Only admin can change roles
  if (role && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden: Cannot change role' });
  }
  
  users[userIndex] = {
    ...users[userIndex],
    name: name || users[userIndex].name,
    email: email || users[userIndex].email,
    role: role || users[userIndex].role
  };
  
  res.json(users[userIndex]);
});

app.delete('/users/:id', authenticateToken, (req, res) => {
  // Check if user has admin role
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden: Admin access required' });
  }
  
  const userIndex = users.findIndex(u => u.id === parseInt(req.params.id));
  
  if (userIndex === -1) return res.status(404).json({ error: 'User not found' });
  
  const deletedUser = users[userIndex];
  users = users.filter(u => u.id !== parseInt(req.params.id));
  
  res.json(deletedUser);
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(PORT, () => {
  console.log(`REST API server running on port ${PORT}`);
  console.log(`API documentation available at http://localhost:${PORT}/api-docs`);
});

module.exports = app; // For testing