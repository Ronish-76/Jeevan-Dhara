const mongoose = require('mongoose');

const donorSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email: { type: String, required: true },
  phone: { type: String, required: true },
  location: { type: String, required: true },
  age: { type: Number, required: true },
  bloodGroup: { type: String, required: true, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  password: { type: String, required: true },
  healthProblems: { type: String },
  lastDonationDate: { type: Date },
  isAvailable: { type: Boolean, default: false },
  donationCapability: { type: String, required: true, enum: ['Yes', 'No'] }
}, { timestamps: true });



module.exports = mongoose.model('Donor', donorSchema);