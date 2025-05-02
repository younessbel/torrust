const express = require('express');
const router = express.Router();
const Babysitter = require('../models/babysitter'); 
const auth = require('../middlewares/auth'); // Import the auth middleware

// Update babysitter availability
router.put('/updateAvailability', auth, async (req, res) => {
  try {
    if (req.user.type !== 'Babysitter') {
      return res.status(403).json({ message: 'Only babysitters can update availability' });
    }

    const { available } = req.body;

    const updatedBabysitter = await Babysitter.findByIdAndUpdate(
      req.user.id, 
      { available },
      { new: true }
    );

    if (!updatedBabysitter) {
      return res.status(404).json({ message: 'Babysitter not found' });
    }

    res.status(200).json({ message: 'Availability updated successfully', babysitter: updatedBabysitter });
  } catch (error) {
    res.status(500).json({ message: 'Something went wrong', error });
  }
});

module.exports = router;
