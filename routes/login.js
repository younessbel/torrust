const { Router } = require('express');
const router = Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const Babysitter = require('../models/babysitter');
const Mother = require('../models/mother');

// ✅ Helper function to send structured responses
function sendResponse(res, statusCode, message, access = '', refresh = '', profilePicture = null) {
  res.status(statusCode).json({ message, access, refresh, profilePicture });
}

// ✅ Babysitter Login
router.post('/login/babysitter', async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return sendResponse(res, 400, 'Please provide phone number or full name and password');
    }

    const query = isNaN(identifier) ? { fullname: identifier } : { phone_number: identifier };
    const babysitter = await Babysitter.findOne(query);

    if (!babysitter) {
      return sendResponse(res, 404, 'User not found');
    }

    const isMatch = await bcrypt.compare(password, babysitter.password);
    if (!isMatch) {
      return sendResponse(res, 401, 'Incorrect credentials or password');
    }

    const accessToken = jwt.sign({ userId: babysitter._id }, process.env.SECRET_KEY, { expiresIn: '15m' });
    const refreshToken = jwt.sign({ userId: babysitter._id }, process.env.REFRESH_SECRET_KEY, { expiresIn: '7d' });

    babysitter.refreshToken = refreshToken;
    await babysitter.save();

    const profilePictureUrl = babysitter.profilePhoto
      ? `http://localhost:4000/${babysitter.profilePhoto}`
      : null;

    sendResponse(res, 200, 'Login successful', accessToken, refreshToken, profilePictureUrl);
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, 'Error logging in');
  }
});

// ✅ Mother Login
router.post('/login/mother', async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return sendResponse(res, 400, 'Please provide phone number or full name and password');
    }

    const query = isNaN(identifier) ? { fullName: identifier } : { phoneNumber: identifier };
    const mother = await Mother.findOne(query);

    if (!mother) {
      return sendResponse(res, 404, 'User not found');
    }

    const isMatch = await bcrypt.compare(password, mother.password);
    if (!isMatch) {
      return sendResponse(res, 401, 'Incorrect password');
    }

    const accessToken = jwt.sign({ userId: mother._id }, process.env.SECRET_KEY, { expiresIn: '15m' });
    const refreshToken = jwt.sign({ userId: mother._id }, process.env.REFRESH_SECRET_KEY, { expiresIn: '7d' });

    mother.refreshToken = refreshToken;
    await mother.save();

    const profilePictureUrl = mother.profilePicture
      ? `http://localhost:4000/${mother.profilePicture}`
      : null;

    sendResponse(res, 200, 'Login successful', accessToken, refreshToken, profilePictureUrl);
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, 'Error logging in');
  }
});

// ✅ Token Refresh
router.post('/token', async (req, res) => {
  const { token } = req.body;

  if (!token) {
    return sendResponse(res, 401, 'Refresh token is required');
  }

  try {
    const payload = jwt.verify(token, process.env.REFRESH_SECRET_KEY);

    const babysitter = await Babysitter.findById(payload.userId);
    const mother = await Mother.findById(payload.userId);
    const user = babysitter || mother;

    if (!user || user.refreshToken !== token) {
      return sendResponse(res, 403, 'Invalid refresh token');
    }

    const newAccessToken = jwt.sign({ userId: user._id }, process.env.SECRET_KEY, { expiresIn: '15m' });
    sendResponse(res, 200, 'Token refreshed successfully', newAccessToken);
  } catch (error) {
    console.error(error);
    sendResponse(res, 403, 'Invalid refresh token');
  }
});

module.exports = router;
