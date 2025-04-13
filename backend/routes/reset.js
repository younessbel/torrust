const express = require('express');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const Babysitter = require('../models/babysitter');
const Mother = require('../models/mother');
require('dotenv').config();

const router = express.Router();

// Nodemailer Transporter
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL,
        pass: process.env.EMAIL_PASS
    }
});
// Forgot Password - Send Confirmation Code
router.post('/forgot-password', async (req, res) => {
    const { email } = req.body;
    try {
        let user = await Babysitter.findOne({ email });
        if (!user) user = await Mother.findOne({ email });
        if (!user) return res.status(404).json({ message: "User not found" });

        const confirmationCode = Math.floor(100000 + Math.random() * 900000); 
        const expiryTime = new Date(Date.now() + 10 * 60 * 1000);
        user.resetCode = confirmationCode;
        user.resetCodeExpires = expiryTime;
        await user.save();

        await transporter.sendMail({
            from: process.env.MAIL_USER,
            to: email,
            subject: "Password Reset Code",
            html: `<h1>Password Reset</h1><p>Your confirmation code is: <strong>${confirmationCode}</strong></p>`
        });

        res.json({ message: "Password reset code sent" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Reset Password - Verify Code and Change Password
router.post('/reset-password', async (req, res) => {
    const { email, confirmationCode, newPassword } = req.body;
    try {
        let user = await Babysitter.findOne({ email });
        if (!user) user = await Mother.findOne({ email });
        if (!user || user.resetCode !== parseInt(confirmationCode)||
        !user.resetCodeExpires ||
        user.resetCodeExpires < new Date()) {
            return res.status(400).json({ message: "Invalid or expired confirmation code" });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        user.password = hashedPassword;
        user.resetCode = null; 
        user.resetCodeExpires = null;
        await user.save();

        res.json({ message: "Password has been reset successfully" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
