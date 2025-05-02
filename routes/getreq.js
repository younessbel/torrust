const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth');
router.get('/requests', auth, async (req, res) => {
    const babysitterId = req.user.id;
    const requests = await BabysittingRequest.find({ babysitter: babysitterId, status: 'pending' })
      .populate('mother', 'fullname email');
    res.json({ requests });
  });
  module.exports = router;