const router = require('express').Router();
const auth = require('../middlewares/auth');
const Babysitter = require('../models/babysitter');

router.get('/babysitter/contacts', auth, async (req, res) => {
  try {
    const sitter = await Babysitter.findById(req.user.id).populate('contacts');
    
    if (!sitter) {
      return res.status(404).json({ message: 'Babysitter not found' });
    }

    res.status(200).json(sitter.contacts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
