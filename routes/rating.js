const router = require('express').Router();
const Babysitter = require('../models/babysitter');
const jwt = require('jsonwebtoken');
const Mother = require('../models/mother');
const authenticateMother = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authorization token required' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.SECRET_KEY);
    const mother = await Mother.findById(decoded.userId);
    if (!mother) return res.status(401).json({ message: 'Invalid user' });
    req.mother = mother;
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};
router.post('/rate-babysitter', authenticateMother, async (req, res) => {
  const { babysitterId, stars } = req.body;

  if (!stars || stars < 1 || stars > 5) {
    return res.status(400).json({ message: 'Rating must be between 1 and 5 stars' });
  }

  try {
    const babysitter = await Babysitter.findById(babysitterId);
    if (!babysitter) return res.status(404).json({ message: 'Babysitter not found' });
    babysitter.ratings = babysitter.ratings || [];
    babysitter.ratings.push({ motherId: req.mother._id, stars });

    await babysitter.save();

    res.json({ message: 'Rating submitted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error submitting rating', error });
  }
});
module.exports = router;
