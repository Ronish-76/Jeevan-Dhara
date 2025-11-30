const mongoose = require('mongoose');

const hospitalSchema = new mongoose.Schema({
  hospitalName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true },
  hospitalRegistrationId: { type: String, required: true, unique: true },
  address: { type: String, required: true },
  city: { type: String, required: true },
  district: { type: String, required: true },
  contactPerson: { type: String, required: true },
  bloodBankFacility: { type: Boolean, default: false },
  emergencyService24x7: { type: Boolean, default: false },
  hospitalType: { 
    type: String, 
    required: true, 
    enum: ['government', 'private', 'teaching', 'community'] 
  },
  medicalLicenseNumber: { type: String, required: true },
  password: { type: String, required: true },
  latitude: { type: Number },
  longitude: { type: Number },
  isVerified: { type: Boolean, default: false },
  verificationStatus: { type: String, enum: ['pending', 'verified', 'rejected'], default: 'pending' }
}, { timestamps: true });

module.exports = mongoose.model('Hospital', hospitalSchema);