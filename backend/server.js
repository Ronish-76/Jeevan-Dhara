
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const mapRoutes = require('./routes/map.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// --- IMPORTANT ---
// Replace with your MongoDB connection string
const MONGO_URI = 'mongodb://localhost:27017/jeevan-dhara';

// Middleware
app.use(cors()); // Enable Cross-Origin Resource Sharing
app.use(express.json());

// Connect to MongoDB
mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB Connected...'))
  .catch(err => console.error('Could not connect to MongoDB', err));

// API Routes
app.use('/api/map', mapRoutes);

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
