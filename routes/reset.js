const express = require('express');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const Babysitter = require('../models/babysitter');
const Mother = require('../models/mother');
const babysitter = require('../models/babysitter');
require('dotenv').config();

const router = express.Router();
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
        if (!user) {
            user = await Mother.findOne({ email });
            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }
        }
        const confirmationCode = Math.floor(100000 + Math.random() * 900000); 
        const expiryTime = new Date(Date.now() + 10 * 60 * 1000);
        user.resetCode = confirmationCode;
        user.resetCodeExpires = expiryTime;
        await user.save();
        await transporter.sendMail({
            from: process.env.MAIL_USER,
            to: email,
            subject: "Password Reset Code",
            html: ` <html>
            <head>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        background-color: #f4f4f9;
                        color: #333;
                        margin: 0;
                        padding: 20px;
                    }
                    .container {
                        background-color: #ffffff;
                        padding: 20px;
                        border-radius: 8px;
                        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
                        max-width: 600px;
                        margin: 0 auto;
                    }
                    h1 {
                        color: #2c3e50;
                        font-size: 24px;
                        text-align: center;
                    }
                    p {
                        font-size: 16px;
                        line-height: 1.5;
                    }
                    h2 {
                        color: #e74c3c;
                        font-size: 32px;
                        text-align: center;
                    }
                    .footer {
                        text-align: center;
                        font-size: 14px;
                        margin-top: 20px;
                        color: #7f8c8d;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>We Received a Request to Reset Your Password</h1>
                    <p>Hi,</p>
                    <p>We received a request to reset your password. To complete the process, please use the confirmation code below:</p>
                    <h2><strong>${confirmationCode}</strong></h2>
                    <p>This code will expire in 10 minutes for your security.</p>
                    <p>If you did not request a password reset, you can safely ignore this email.</p>
                    <div class="footer">
                        <p>Best regards,</p>
                        <p>The Team</p>
                    </div>
                </div>
            </body>
        </html>`
        });
        res.json({ message: "Password reset code sent" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});
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
