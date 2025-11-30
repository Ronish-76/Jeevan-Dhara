const mongoose = require('mongoose');

const requesterSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email: { type: String, required: true },
  phone: { type: String, required: true },
  hospitalName: { type: String, required: true },
  location: { type: String, required: true },
  latitude: { type: Number },
  longitude: { type: Number },
  hospitalLocation: { type: String },
  hospitalPhone: { type: String },
  age: { type: Number, required: true },
  gender: { type: String, required: true, enum: ['Male', 'Female', 'Other'] },
  bloodGroup: { type: String, required: true, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  password: { type: String, required: true },
  fcmToken: { type: String, default: null }
}, { timestamps: true });

module.exports = mongoose.model('Requester', requesterSchema);