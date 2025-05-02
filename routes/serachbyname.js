const express = require('express');
const router = express.Router();
const Babysitter = require('../models/babysitter'); // make sure this path is correct
router.get('/search-babysitter-by-name', async (req, res) => {
  try {
    const nameQuery = req.query.name;
    if (!nameQuery) {
      return res.status(400).json({ message: 'Name query is required' });
    }

    const babysitters = await Babysitter.find({
      fullname: { $regex: nameQuery, $options: 'i' } // case-insensitive search
    });

    res.json(babysitters);
  } catch (error) {
    console.error('Error searching babysitters by name:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
