const { Router } = require('express');
const router = Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const Babysitter = require('../models/babysitter');
Mother = require('../models/mother');
router.post('/login/babysitter', async (req, res) => {
    try {
        const { phone_number, fullname, password } = req.body;
        if ((!phone_number && !fullname) || !password) {
            return res.status(400).send('Please provide phone_number or fullname and password');
        }
        const query = phone_number ? { phone_number } : { fullname };
        const babysitter = await Babysitter.findOne(query);
        if (!babysitter) {
            return res.status(404).send('User not found');
        }
        const isMatch = await bcrypt.compare(password, babysitter.password);
        if (!isMatch) {
            return res.status(401).send('Password does not match');
        }
        const accessToken = jwt.sign({ userId: babysitter._id }, process.env.SECRET_KEY, { expiresIn: '15m' });
        const refreshToken = jwt.sign({ userId: babysitter._id }, process.env.REFRESH_SECRET_KEY, { expiresIn: '7d' });

        babysitter.refreshToken = refreshToken;
        await babysitter.save();

        res.json({ accessToken, refreshToken });
    } catch (error) {
        res.status(500).send('Error logging in user.');
        console.log(error);
    }
});
router.post('/login/mother', async (req, res) => {
    try {
      const { identifier, password } = req.body;
  
      if (!identifier || !password) {
        return res.status(400).send('Please provide phone number or full name and password');
      }
  
      const query = isNaN(identifier) ? { fullName: identifier } : { phoneNumber: identifier };
      const mother = await Mother.findOne(query);
      if (!mother) {
        return res.status(404).send('User not found');
      }
  
      const isMatch = await bcrypt.compare(password, mother.password);
      if (!isMatch) {
        return res.status(401).send('Incorrect password');
      }
  
      const accessToken = jwt.sign({ userId: mother._id }, process.env.SECRET_KEY, { expiresIn: '15m' });
      const refreshToken = jwt.sign({ userId: mother._id }, process.env.REFRESH_SECRET_KEY, { expiresIn: '7d' });
  
      mother.refreshToken = refreshToken;
      await mother.save();
  
      res.json({ accessToken, refreshToken });
    } catch (error) {
      res.status(500).send('Error logging in');
      console.error(error);
    }
  });
router.post('/token', async (req, res) => {
    const { token } = req.body;
    if (!token) {
        return res.status(401).send('Refresh token is required');
      }
    
      try {
        const payload = jwt.verify(token, process.env.REFRESH_SECRET_KEY);
    
        // Try to find user in both collections
        const babysitter = await Babysitter.findById(payload.userId);
        const mother = await Mother.findById(payload.userId);
    
        const user = babysitter || mother;
    
        if (!user || user.refreshToken !== token) {
          return res.status(403).send('Invalid refresh token');
        }
    
        const accessToken = jwt.sign({ userId: user._id }, process.env.SECRET_KEY, { expiresIn: '15m' });
        res.json({ accessToken });
      } catch (error) {
        res.status(403).send('Invalid refresh token');
      }
});

module.exports = router;