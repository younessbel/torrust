const { Router } = require('express');
const router = Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const Babysitter = require('../models/babysitter');
const Mother = require('../models/mother');
const multer = require('multer');
const upload = require('../middlewares/upload');
const { default: mongoose } = require('mongoose');
const nodemailer = require('nodemailer');

// ✅ Configure nodemailer transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL,
    pass: process.env.EMAIL_PASS,
  },
});

// ✅ Helper function to send structured JSON response
function sendResponse(res, statusCode, message, access = '', refresh = '', profilePicture = null) {
  res.status(statusCode).json({ message, access, refresh, profilePicture });
}

// ✅ Helper function to send OTP Email
async function sendOTPEmail(email) {
  const mailOptions = {
    from: process.env.EMAIL_ADDRESS,
    to: email,
    subject: 'Welcome to TotTrust!',
    html: `
      <div style="font-family: Arial, sans-serif; color: #333; padding: 20px;">
        <h2>Hi there 👋</h2>
        <p>Thanks for joining <strong>TotTrust</strong>!</p>
        <p>You registered with email: <strong>${email}</strong>.</p>
        <p>If this wasn't you, you can delete your account here:</p>
        <a href="http://localhost:4000/delete?email=${encodeURIComponent(email)}" 
           style="background-color: #e74c3c; padding: 10px 15px; color: white; text-decoration: none; border-radius: 5px;">
           Delete My Account
        </a>
        <p style="margin-top:20px;">Otherwise, welcome aboard! ❤️</p>
      </div>
    `
  };
  await transporter.sendMail(mailOptions);
}

// ✅ Babysitter Registration
router.post('/register_babysitter', upload.single('profilePhoto'), async (req, res) => {
  try {
    const { fullname, phone_number, age, email, pref_location, exp, age_grps, password, confirmPassword, national_card_number } = req.body;

    if (!password || !confirmPassword || password.trim() !== confirmPassword.trim()) {
      return sendResponse(res, 400, "Passwords don't match");
    }

    const existingBabysitter = await Babysitter.findOne({ email });
    if (existingBabysitter) {
      return sendResponse(res, 400, 'Email already exists');
    }

    const hashedPassword = await bcrypt.hash(password, parseInt(process.env.ROUNDS, 10));

    const newBabysitter = new Babysitter({
      fullname,
      phone_number,
      age: parseInt(age),
      email,
      pref_location,
      exp: parseInt(exp),
      age_grps: Array.isArray(age_grps) ? age_grps : JSON.parse(age_grps),
      password: hashedPassword,
      national_card_number,
      profilePhoto: req.file ? req.file.path : undefined,
    });

    await newBabysitter.save();
    await sendOTPEmail(email);

    const profilePictureUrl = newBabysitter.profilePhoto
      ? `http://localhost:4000/${newBabysitter.profilePhoto}`
      : null;
    sendResponse(res, 201, 'Babysitter registered successfully! OTP sent.', '', '', profilePictureUrl);
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, 'Error registering babysitter');
  }
});

// ✅ Mother Registration
router.post('/register_mother', upload.single('profilePhoto'), async (req, res) => {
  try {
    const { fullname, phone_number, email, password, confirmPassword } = req.body;

    if (!password || !confirmPassword || password.trim() !== confirmPassword.trim()) {
      return sendResponse(res, 400, "Passwords don't match");
    }

    const existingMother = await Mother.findOne({ email });
    if (existingMother) {
      return sendResponse(res, 400, 'Email already exists');
    }

    const hashedPassword = await bcrypt.hash(password, parseInt(process.env.ROUNDS, 10));

    const newMother = new Mother({
      fullname,
      phone_number,
      email,
      password: hashedPassword,
      profilePhoto: req.file ? req.file.path : undefined,
    });

    await newMother.save();
    await sendOTPEmail(email);

    const profilePictureUrl = newMother.profilePhoto
      ? `http://localhost:4000/${newMother.profilePhoto}`
      : null;

    sendResponse(res, 201, 'Mother registered successfully! OTP sent.', '', '', profilePictureUrl);

  } catch (error) {
    console.error(error);
    sendResponse(res, 500, 'Error registering mother');
  }
});
console.log("MongoDB Ready State:", mongoose.connection.readyState);

module.exports = router;
