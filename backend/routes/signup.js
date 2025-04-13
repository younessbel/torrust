const {Router} = require('express');
const router = Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt'); 
const Babysitter = require('../models/babysitter'); 
const multer = require('multer');
const Mother = require('../models/mother');
const upload = require('../middlewares/upload');

router.post('/register_babysitter', upload.single('profilePhoto'), async (req, res) => {
  try {
    const { 
      fullname, 
      phone_number, 
      age, 
      email, 
      pref_location, 
      exp, 
      age_grps, 
      password, 
      confirmPassword, 
      national_card_number 
    } = req.body;

    if (password !== confirmPassword) {
      return res.status(400).json({ message: "Passwords don't match" });
    }

    const hashedPassword = await bcrypt.hash(password, parseInt(process.env.ROUNDS, 10));

    const newBabbysitter = new Babysitter({
      fullname,
      phone_number,
      age,
      email,
      pref_location,
      exp,
      age_grps,
      password: hashedPassword,
      national_card_number,
      profilePhoto: req.file ? req.file.path : undefined
    });

    
    await newBabbysitter.save();
    res.redirect('/');
  } catch (error) {
    res.redirect('/login');
    console.log(error);
  }
});

    router.post('/register_mother', upload.single('profilePhoto'), async (req, res) => {
        const { fullname, phone_number, password, confirmPassword, email } = req.body;
      
        if (password !== confirmPassword) {
          return res.status(400).json({ message: "Passwords don't match" });
        }
      
        try {
          const existingMother = await Mother.findOne({ email });
          if (existingMother) {
            return res.status(400).json({ message: 'Email already exists' });
          }
      
          const hashedPassword = await bcrypt.hash(password, parseInt(process.env.ROUNDS, 10));
          const newMother = new Mother({
            fullname,
            phone_number,
            email,
            password: hashedPassword,
            profilePhoto: req.file ? req.file.path : undefined,
          });
      
          await newMother.save();
          res.redirect('/'); 
        } catch (error) {
          res.status(500).json({ message: 'Error registering mother', error });
        }
      });
    module.exports = router;