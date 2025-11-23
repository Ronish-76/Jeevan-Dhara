
const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const Location = require('./models/location.model');

// --- IMPORTANT ---
// Replace with your MongoDB connection string
const MONGO_URI = 'mongodb://localhost:27017/jeevan-dhara';

const seedDB = async () => {
  try {
    await mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log('MongoDB Connected...');

    // Clear existing data
    await Location.deleteMany({});
    console.log('Cleared existing locations.');

    // Read and parse the JSON file
    const locationsPath = path.join(__dirname, 'data', 'locations.json');
    const locations = JSON.parse(fs.readFileSync(locationsPath, 'utf-8'));

    // Insert new data
    await Location.insertMany(locations);
    console.log('Database seeded successfully!');

  } catch (err) {
    console.error('Error seeding database:', err);
  } finally {
    // Close the connection
    mongoose.connection.close();
    console.log('MongoDB connection closed.');
  }
};

seedDB();
