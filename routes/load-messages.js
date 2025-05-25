const express = require('express');
const router = express.Router();
const Message = require('../models/message');

// GET /messages/:user1Id/:user2Id
router.get('/messages/:user1Id/:user2Id', async (req, res) => {
    try {
        const { user1Id, user2Id } = req.params;
        const messages = await Message.find({
            $or: [
                { sender: user1Id, recipient: user2Id },
                { sender: user2Id, recipient: user1Id }
            ]
        }).sort({ timestamp: 1 });

        res.json(messages);
    } catch (err) {
        res.status(500).json({ error: 'Failed to load messages' });
    }
});

module.exports = router;
