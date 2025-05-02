const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth');
router.post('/requests/:requestId/accept', auth, async (req, res) => {
    const { requestId } = req.params;
    const request = await BabysittingRequest.findById(requestId)
      .populate('mother')
      .populate('babysitter');
  
    if (!request) return res.status(404).json({ error: 'Request not found' });
  
    request.status = 'accepted';
    await request.save();
  
    // Add to babysitter's acceptedRequests
    const babysitter = await Babysitter.findById(request.babysitter._id);
    babysitter.acceptedRequests.push({
      mother: request.mother._id,
      childName: request.child.name,
      childAge: request.child.age,
      babysittingDate: request.child.babysittingDate
    });
    await babysitter.save();
  
    // Create Notification
    await Notification.create({
      user: request.mother._id,
      userType: 'Mother',
      message: `Your babysitting request for ${request.child.name} was accepted.`,
      type: 'accepted'
    });
  
    res.json({ message: 'Request accepted and mother notified' });
  });
  module.exports = router;