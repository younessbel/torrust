const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth');
router.get('/mother/contacts', auth, async (req, res) => {
    const mother = await Mother.findById(req.user.id).populate('contacts');
    res.json(mother.contacts);
  });
module.exports = router;