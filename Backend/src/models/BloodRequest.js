const mongoose = require('mongoose');

const bloodRequestSchema = new mongoose.Schema({
  patientName: { type: String, required: true },
  bloodGroup: { type: String, required: true, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  hospitalName: { type: String, required: true },
  location: { type: String, required: true },
  contactNumber: { type: String, required: true },
  additionalDetails: { type: String },
  notifyViaEmergency: { type: Boolean, default: false },
  requester: { type: mongoose.Schema.Types.ObjectId, ref: 'Requester', required: true }
}, { timestamps: true });

module.exports = mongoose.model('BloodRequest', bloodRequestSchema);