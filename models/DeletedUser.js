const mongoose = require('mongoose');

const deletedUserSchema = new mongoose.Schema({
  fullname: String,
  email: String,
  phone_number: String,
  userType: {
    type: String,
    enum: ['Mother', 'Babysitter'],
    required: true
  },
  deletedAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

module.exports = mongoose.model('DeletedUser', deletedUserSchema);
