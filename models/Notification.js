const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, refPath: 'userType', required: true },
  userType: { type: String, enum: ['Mother', 'Babysitter'], required: true },
  message: { type: String, required: true },
  read: { type: Boolean, default: false },
  type: { type: String, enum: ['accepted', 'completed'], default: 'accepted' },
}, { timestamps: true });

module.exports = mongoose.model('Notification', notificationSchema);
