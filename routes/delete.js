const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Mother = require('../models/mother');
const Babysitter = require('../models/babysitter');
const DeletedUser = require('../models/DeletedUser'); // import the new model

router.delete('/delete-account', async (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authorization token required' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.SECRET_KEY);

    // Try to find the user in either collection
    let user = await Mother.findById(decoded.userId);
    let userType = 'Mother';

    if (!user) {
      user = await Babysitter.findById(decoded.userId);
      userType = 'Babysitter';
    }

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Log the deleted user's info
    await DeletedUser.create({
      fullname: user.fullname,
      email: user.email,
      phone_number: user.phone_number,
      userType
    });

    // Delete the user
    await user.deleteOne();

    res.json({ message: 'Account deleted and archived successfully' });
  } catch (err) {
    console.error(err);
    res.status(401).json({ message: 'Invalid or expired token' });
  }
});

module.exports = router;
