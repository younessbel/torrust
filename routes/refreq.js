const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth');
router.delete('/requests/:requestId/refuse', auth, async (req, res) => {
    const { requestId } = req.params;
    await BabysittingRequest.findByIdAndDelete(requestId);
    res.json({ message: 'Request refused and deleted' });
  });
  module.exports = router;
  