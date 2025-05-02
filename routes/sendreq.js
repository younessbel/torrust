const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth');
router.post('/send-request/:babysitterId', auth, async (req, res) => {
    const { babysitterId } = req.params;
    const { name, age, date, time,message } = req.body;
    const motherId = req.user.id;
  
    const request = new BabysittingRequest({
      mother: motherId,
      babysitter: babysitterId,
      child: { name, age, babysittingDate: { date, time }, message },
      status: 'pending'
    });
    await request.save();
    res.status(201).json({ message: 'Request sent successfully' });
  });
  module.exports = router;