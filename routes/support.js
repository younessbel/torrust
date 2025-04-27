const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');
const Mother = require('../models/mother'); 
const Babysitter = require('../models/babysitter');

router.post('/contact-support', async (req, res) => {
  const {  message } = req.body;

  if ( !message) {
    return res.status(400).json({ message: 'Email and message are required.' });
  }
  try {
    const user = req.mother || req.babysitter;
    const userEmail = user?.email;

    if (!userEmail) {
      return res.status(403).json({ message: 'Unauthorized. Email not found in token.' });
    }

  // Set up your email transport
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL,
      pass: process.env.EMAIL_PASS 
    }
  });

  const mailOptions = {
    from: process.env.EMAIL,
    to: process.env.EMAIL,
    replyTo: userEmail,
    subject: 'TotTrust Support Request',
    text: message
  };
  await transporter.sendMail(mailOptions);
  res.json({ message: 'Support message sent successfully!' });
  
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to send support message.', error });
  }
});

module.exports = router;
