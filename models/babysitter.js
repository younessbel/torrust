const mongoose = require("mongoose");

const babysitterSchema = new mongoose.Schema({
  fullname: {
    type: String,
    required: true,
    trim: true,
  },
  phone_number: {
    type: String,
    required: true,
    trim: true,
  },
  age: {
    type: Number,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  pref_location: {
    type: String,
    required: true,
  },
  exp: {
    type: Number,
    required: true,
  },
  age_grps: {
    type: [String], 
    required: true,
  },
  password: {
    type: String,
    required: true,
  },
  national_card_number: {
    type: String,
    required: true,
  },
  profilePhoto: {
    type: String, 
  },
  resetCode: { 
    type: Number
  },
  resetCodeExpires: {
    type: Date, 
  },
  ratings: [{
    motherId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Mother',
      required: true
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },
    comment: {
      type: String
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  bio: {
    type: String,
    default: ""
  },
  acceptedRequests: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'BabysittingRequest'
  }],
  refreshToken: {
    type: String, 
    default: "",
  },
  
  available: { 
    type: Boolean,
    default: true  // true means the babysitter is generally available
  },contacts: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'mothers'  // This points to the Mother model
  }]
  
}, { timestamps: true });

module.exports = mongoose.model("Babysitter", babysitterSchema);
