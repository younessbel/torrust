const router = require('express').Router();
const Babysitter = require('../models/babysitter');
const Mother = require('../models/mother');
router.get('/delete', (req, res) => {
    const { email } = req.query;
    res.send(`
    <p>Are you sure you want to delete the account for <strong>${email}</strong>?</p>
    <form method="POST" action="/delete">
      <input type="hidden" name="email" value="${email}" />
      <button type="submit" style="padding: 10px 20px; background: red; color: white; border: none; border-radius: 5px;">
        Yes, Delete My Account
      </button>
    </form>
    `);
  });
  
router.post('/delete', async (req, res) => {
    const { email } = req.body;  
    try {
      let user = await Babysitter.findOne({ email });
      if (!user) user = await Mother.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
      await user.deleteOne();
      res.json({ message: 'Account deleted successfully' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error deleting account', error });
    }

  });
module.exports = router;  