const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Mother = require('../models/mother');
const Babysitter = require('../models/babysitter');
require('dotenv').config();

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Access token missing' });

  jwt.verify(token, process.env.JWT_SECRET, (err, mother) => {
    if (err) return res.status(403).json({ message: 'Invalid token' });
    req.mother = mother;
    next();
  });
}
router.get('/recommended-babysitters', authenticateToken, async (req, res) => {
  try {
    const motherData = await Mother.findById(req.mother.id);
    if (!motherData) return res.status(404).json({ message: 'Mother not found' });

    const location = motherData.pref_location;
    const preferredAgeGroups = motherData.age_grps || [];

    const babysitters = await Babysitter.find({
      pref_location: location,
      age_grps: { $in: preferredAgeGroups },
      available: true
    }).lean();

    const babysittersWithRatings = babysitters.map(babysitter => {
      const ratings = babysitter.ratings || [];
      const avgRating = ratings.length > 0 ? ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length : 0;
      return { ...babysitter, avgRating };
    });

    babysittersWithRatings.sort((a, b) => b.avgRating - a.avgRating);
    res.json(babysittersWithRatings);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Something went wrong', error });
  }
});
router.get('/saved-babysitters', authenticateToken, async (req, res) => {
  try {
    const motherData = await Mother.findById(req.mother.id).populate({
      path: 'saved_babysitters',
      match: { available: true }
    }).lean();

    if (!motherData) return res.status(404).json({ message: 'Mother not found' });

    const savedBabysitters = (motherData.saved_babysitters || []).map(babysitter => {
      const ratings = babysitter.ratings || [];
      const avgRating = ratings.length > 0 ? ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length : 0;
      return { ...babysitter, avgRating };
    });

    savedBabysitters.sort((a, b) => b.avgRating - a.avgRating);
    res.json(savedBabysitters);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Something went wrong', error });
  }
});
router.get('/favorite-babysitters', authenticateToken, async (req, res) => {
  try {
    const motherData = await Mother.findById(req.mother.id).populate({
      path: 'favorite_babysitters',
      match: { available: true }
    }).lean();

    if (!motherData) return res.status(404).json({ message: 'Mother not found' });

    const favoriteBabysitters = (motherData.favorite_babysitters || []).map(babysitter => {
      const ratings = babysitter.ratings || [];
      const avgRating = ratings.length > 0 ? ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length : 0;
      return { ...babysitter, avgRating };
    });

    favoriteBabysitters.sort((a, b) => b.avgRating - a.avgRating);
    res.json(favoriteBabysitters);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Something went wrong', error });
  }
});


module.exports = router;
