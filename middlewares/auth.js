const jwt = require('jsonwebtoken');
const Mother = require('../models/mother');
const Babysitter = require('../models/babysitter');

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.SECRET_KEY); // ✅ Match login

    let user = await Mother.findById(decoded.userId);
    if (user) {
      req.user = { id: user._id, type: 'Mother' };
      return next();
    }

    user = await Babysitter.findById(decoded.userId);
    if (user) {
      req.user = { id: user._id, type: 'Babysitter' };
      return next();
    }

    return res.status(404).json({ message: 'User not found' });

  } catch (error) {
    console.error('Auth error:', error);
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};
