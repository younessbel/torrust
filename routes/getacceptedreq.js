const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth'); // Import auth middleware
const BabysittingRequest = require('../models/BabysittingRequest'); // Import the BabysittingRequest model

// GET /requests/accepted
router.get('/requests/accepted', auth, async (req, res) => {
  try {
    // Make sure only babysitter can access
    if (req.user.type !== 'Babysitter') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const babysitterId = req.user.id; // Get babysitter ID from token

    const acceptedRequests = await BabysittingRequest.find({ babysitter: babysitterId, status: 'accepted' })
      .populate('mother', 'fullName phoneNumber')     // populate mother basic info
      .populate('babysitter', 'fullname phone_number') // populate babysitter basic info
      .sort({ createdAt: -1 }); // newest first

    res.json({ acceptedRequests });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching accepted requests' });
  }
});

module.exports = router;
