const mongoose = require("mongoose");

const motherSchema = new mongoose.Schema({
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
    email:{
      type:String,
      required:true,
      unique:true,
    },
    password: {
      type: String,
      required: true,
    },
    favorite_babysitters: {
      type: [String],
      ref: 'babysitters'
    },
    profilePhoto:{
      type:String,
    },
    resetCode: {
      type: Number,
    },
    resetCodeExpires: {
      type: Date,
    },
    refreshToken: {
      type: String,
      default: "",
    },
    preferred_age_groups: {
      type: [String],
      default: []
    },
    pref_location: {
      type: String,
      default: ""
    },
    saved_babysitters: {
      type: [String],
      ref: 'babysitters'
    },
    
    contacts: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'babysitters'
    }]
,    
    bio: {
  type: String,
  default: "",
},
  }, { timestamps: true });
  module.exports = mongoose.model("Mother", motherSchema);
