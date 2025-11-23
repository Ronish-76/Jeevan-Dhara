
const mongoose = require('mongoose');

const locationSchema = new mongoose.Schema({
  name: { type: String, required: true },
  displayAddress: { type: String, required: true },
  type: { type: String, enum: ['hospital', 'bloodBank', 'donor'], required: true },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      required: true,
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true,
    },
  },
  bloodInventory: { type: Map, of: Number },
  isAvailable: { type: Boolean, default: true },
});

// Create the 2dsphere index for geospatial queries
locationSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Location', locationSchema);
