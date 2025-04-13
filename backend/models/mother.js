const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

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
      require:true,
      unique:true,
    },
    password: {
      type: String,
      required: true,
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
  }, { timestamps: true });
  
  
  
  module.exports = mongoose.model("Mother", motherSchema);