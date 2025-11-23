const mongoose = require('mongoose');

const bloodStockSchema = new mongoose.Schema({
  hospital: { type: mongoose.Schema.Types.ObjectId, ref: 'Hospital' }, // Made optional
  bloodBank: { type: mongoose.Schema.Types.ObjectId, ref: 'BloodBank' }, // Added field
  bloodGroup: { type: String, required: true, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  units: { type: Number, required: true, min: 0 },
  expiryDate: { type: Date, required: true },
  donorId: { type: String },
  collectionDate: { type: Date, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('BloodStock', bloodStockSchema);