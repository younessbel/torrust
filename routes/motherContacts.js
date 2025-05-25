const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Mother = require('../models/mother');
const Babysitter = require('../models/babysitter');

const auth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.SECRET_KEY);

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


router.get('/mother/contacts', auth, async (req, res) => {
  try {
    // Try to find the current user in either collection
    let user = await Mother.findById(req.user.id);
    if (!user) {
      user = await Babysitter.findById(req.user.id);
    }
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    if (!user.contacts) {
      user.contacts = [];
      await user.save();
    }
    const contactsIds = user.contacts;
    
    const contactMothersPromise = Mother.find({
      _id: { $in: contactsIds }
    });
    const contactBabysittersPromise = Babysitter.find({
      _id: { $in: contactsIds }
    });
    
    const [contactMothers, contactBabysitters] = await Promise.all([
      contactMothersPromise,
      contactBabysittersPromise
    ]);
    
    // Merge the arrays into a single contacts array
    const contacts = [...contactMothers, ...contactBabysitters];
    res.json(contacts);  // modified response
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/babysitter/contacts', auth, async (req, res) => {
  try {
    // Try to find the current user in either collection
    let user = await Mother.findById(req.user.id);
    if (!user) {
      user = await Babysitter.findById(req.user.id);
    }
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const contactsIds = user.contacts || [];
    
    const contactMothersPromise = Mother.find({
      _id: { $in: contactsIds }
    });
    const contactBabysittersPromise = Babysitter.find({
      _id: { $in: contactsIds }
    });
    
    const [contactMothers, contactBabysitters] = await Promise.all([
      contactMothersPromise,
      contactBabysittersPromise
    ]);
    
    // Merge the arrays into a single contacts array
    const contacts = [...contactMothers, ...contactBabysitters];
    res.json(contacts);  // modified response
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;