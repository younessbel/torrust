const express =require('express');
const router = express.Router();
const BabysittingRequest = require('../models/BabysittingRequest');
const auth =require('../middlewares/auth');
router.post('/add-child-offline', auth, async (req, res) => {
    const { name, age, babysittingDate } = req.body;
  
    if (!name || !age || !babysittingDate?.date|| !babysittingDate?.time) {
      return res.status(400).json({ message: 'Incomplete child or date info' });
    }
  
    try {
      const newRequest = new BabysittingRequest({
        mother: '661dbfc37982954f1cf429ab',
        babysitter: req.babysitter._id,
        child: {
          name,
          age,
          babysittingDate
        },
        status: 'accepted'
      });
  
      await newRequest.save();
      res.status(201).json({ message: 'Child added (offline) successfully'});
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Error saving offline child request' });
    }
  });
module.exports = router;  