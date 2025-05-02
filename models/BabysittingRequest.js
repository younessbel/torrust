const mongoose = require('mongoose');
const requestSchema = new mongoose.Schema({
  mother: { type: mongoose.Schema.Types.ObjectId, ref: 'Mother', required: true },
  babysitter: { type: mongoose.Schema.Types.ObjectId, ref: 'Babysitter', required: true },
  child: {
    name: { type: String, required: true },
    age: { type: Number, required: true },
    babysittingDate: {
      date: { type: String, required: true },
      time: { type: String, required: true }
    },
    message: { type: String, required: true } ,
  },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'refused', 'completed'],
    default: 'pending'
  }
}, { timestamps: true });

module.exports = mongoose.model('BabysittingRequest', requestSchema);