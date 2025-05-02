const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Mother = require('../models/mother');
const Babysitter = require('../models/babysitter');
const router = require('express').Router();
router.post('/change-password', async (req, res) => {
  const authHeader = req.headers.authorization;
  const { currentPassword, newPassword } = req.body;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authorization token required' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.SECRET_KEY);
    let user = await Mother.findById(decoded.userId);
    if (!user) {
      user = await Babysitter.findById(decoded.userId);
    }

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Current password is incorrect' });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();

    res.json({ message: 'Password changed successfully' });
  } catch (err) {
    console.error(err);
    res.status(401).json({ message: 'Invalid or expired token' });
  }
});
module.exports = router;