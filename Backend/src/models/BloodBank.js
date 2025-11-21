const mongoose = require('mongoose');

const bloodBankSchema = new mongoose.Schema({
  bloodBankName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true },
  registrationNumber: { type: String, required: true, unique: true },
  fullAddress: { type: String, required: true },
  city: { type: String, required: true },
  district: { type: String, required: true },
  contactPerson: { type: String, required: true },
  designation: { type: String, required: true },
  storageCapacity: { type: Number, required: true },
  emergencyService24x7: { type: Boolean, default: false },
  componentSeparation: { type: Boolean, default: false },
  apheresisService: { type: Boolean, default: false },
  password: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model('BloodBank', bloodBankSchema);