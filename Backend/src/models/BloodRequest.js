const mongoose = require('mongoose');

const bloodRequestSchema = new mongoose.Schema({
  patientName: { type: String, required: true },
  patientPhone: { type: String, required: true },
  bloodGroup: { type: String, required: true, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  hospitalName: { type: String, required: true },
  location: { type: String, required: true },
  contactNumber: { type: String, required: true },
  additionalDetails: { type: String },
  units: { type: Number, required: true, default: 1 },
  notifyViaEmergency: { type: Boolean, default: false },
  status: { type: String, enum: ['pending', 'accepted', 'fulfilled', 'cancelled'], default: 'pending' },
  requester: { type: mongoose.Schema.Types.ObjectId, ref: 'Requester', required: true },
  donor: { type: mongoose.Schema.Types.ObjectId, ref: 'Donor' }
}, { timestamps: true });

module.exports = mongoose.model('BloodRequest', bloodRequestSchema);