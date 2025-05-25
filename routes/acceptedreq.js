// routes/acceptedreq.js
const express    = require('express');
const router     = express.Router();
const auth       = require('../middlewares/auth');

const BabysittingRequest = require('../models/BabysittingRequest');
const Babysitter         = require('../models/babysitter');
const Notification       = require('../models/Notification');

router.post('/requests/:requestId/accept', auth, async (req, res) => {
  const { requestId } = req.params;

  try {
    // 1) Load the request
    const request = await BabysittingRequest.findById(requestId)
      .populate('mother')
      .populate('babysitter');
    if (!request) {
      return res.status(404).json({ error: 'Request not found' });
    }

    // 2) Extract date & time
    const bDate = request.child?.babysittingDate;
    if (!bDate?.date || !bDate?.time) {
      return res.status(400).json({ error: 'Missing date or time in request' });
    }

    // 3) Normalize dateOnly (strip any time) and split time into parts
    const dateOnly = bDate.date.split('T')[0];  // e.g. "2025-05-23"
    let [hour, minute] = bDate.time.split(':');  

    // Zero-pad each component
    hour   = hour.padStart(2, '0');    // "14"
    minute = (minute || '0').padStart(2, '0'); // "00" if missing leading zero

    // Build ISO string and log it
    const isoString = `${dateOnly}T${hour}:${minute}:00`;
    console.log('→ ISO string for parsing:', isoString);

    // 4) Convert to Date and validate
    const scheduledAt = new Date(isoString);
    if (isNaN(scheduledAt.getTime())) {
      return res.status(400).json({ error: `Invalid date/time format (“${isoString}”)` });
    }

    // 5) Mark the request accepted
    request.status = 'accepted';
    await request.save();

    // 6) Append to sitter.acceptedRequests
    const sitter = await Babysitter.findById(request.babysitter._id);
    if (!sitter) {
      return res.status(404).json({ error: 'Babysitter not found' });
    }

    sitter.acceptedRequests.push({
      mother:          request.mother._id,
      childName:       request.child.name,
      childAge:        request.child.age,
      babysittingDate: scheduledAt
    });
    await sitter.save();

    // 7) Notify the mother
    await Notification.create({
      user:     request.mother._id,
      userType: 'Mother',
      message:  `Your babysitting request for ${request.child.name} on ${scheduledAt.toISOString()} was accepted.`,
      type:     'accepted'
    });

    return res.json({ message: 'Request accepted and mother notified' });
  }
  catch (err) {
    console.error('Error accepting request:', err);
    return res.status(500).json({ error: 'Failed to accept request' });
  }
});

module.exports = router;
