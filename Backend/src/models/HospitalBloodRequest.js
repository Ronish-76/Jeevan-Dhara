const mongoose = require('mongoose');

const hospitalBloodRequestSchema = new mongoose.Schema({
  hospital: { type: mongoose.Schema.Types.ObjectId, ref: 'Hospital', required: true },
  patientName: { type: String }, 
  bloodGroup: { type: String, required: true, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  unitsRequired: { type: Number, required: true, min: 1 },
  urgency: { type: String, enum: ['low', 'medium', 'high', 'critical'], default: 'medium' },
  requestedFrom: { type: String, enum: ['blood_bank', 'donor'], required: true },
  status: { type: String, enum: ['pending', 'approved', 'fulfilled', 'cancelled'], default: 'pending' },
  deliveryStatus: { type: String, enum: ['not_started', 'in_transit', 'delivered'], default: 'not_started' },
  notifyViaEmergency: { type: Boolean, default: false }, // Added field to explicitly store emergency flag
  notes: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('HospitalBloodRequest', hospitalBloodRequestSchema);