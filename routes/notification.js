const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth');
router.get('/notifications', auth, async (req, res) => {
    const userId = req.user.id;
    const userType = req.user.type; // Include 'type' in your token
  
    const notifications = await Notification.find({ user: userId, userType }).sort({ createdAt: -1 });
  
    res.json({ notifications });
  });
  module.exports = router;