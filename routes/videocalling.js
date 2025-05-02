const { Server } = require('socket.io');
const fs = require('fs');
const path = require('path');
const jwt = require('jsonwebtoken');

let ioInstance = null;

function authenticateSocket(socket, next) {
  const token = socket.handshake.auth.token;
  if (!token) {
    return next(new Error("Authentication token missing"));
  }
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return next(new Error("Invalid token"));
    socket.user = user;
    next();
  });
}

function initSocket(server) {
  if (ioInstance) return ioInstance;

  const io = new Server(server, {
    cors: {
      origin: '*',
    },
  });

  io.use(authenticateSocket);

  io.on('connection', (socket) => {
    console.log('User connected:', socket.user);
    socket.join(socket.user.id);

    socket.on('call-user', ({ calleeId, offer }) => {
      io.to(calleeId).emit('incoming-call', {
        from: socket.user.id,
        offer,
      });
    });

    socket.on('answer-call', ({ callerId, answer }) => {
      io.to(callerId).emit('call-answered', {
        from: socket.user.id,
        answer,
      });
    });

    socket.on('send-ice-candidate', ({ targetId, candidate }) => {
      io.to(targetId).emit('ice-candidate', {
        from: socket.user.id,
        candidate,
      });
    });

    socket.on('send-message', async ({ to, type, content }) => {
      const allowedTypes = ['text', 'image'];
      const Mother = require('./models/mother');
      const Babysitter = require('./models/babysitter');

      async function addContact(userId, contactId) {
  
      await Promise.all([
       Mother.findByIdAndUpdate(userId, { $addToSet: { contacts: contactId } }),
       Babysitter.findByIdAndUpdate(userId, { $addToSet: { contacts: contactId } }),
       Mother.findByIdAndUpdate(contactId, { $addToSet: { contacts: userId } }),
       Babysitter.findByIdAndUpdate(contactId, { $addToSet: { contacts: userId } })
  ]);
}
      if (!allowedTypes.includes(type)) {
        return socket.emit('error', { message: 'Invalid message type' });
      }
      io.to(to).emit('receive-message', {
        from: socket.user.id,
        type,
        content,
        timestamp: new Date(),
      });
      try {
        await addContact(socket.user.id, to);
      } catch (err) {
        console.error("Error adding to contacts:", err);
      }
    });

    socket.on('send-file', (data) => {
      const { to, type, content } = data;
      const fileName = Date.now() + '-' + type.split('/')[1];
      const filePath = path.join(__dirname, 'uploads', fileName);
      fs.writeFile(filePath, Buffer.from(content), (err) => {
        if (err) {
          console.error('Error saving file:', err);
          return socket.emit('error', { message: 'File upload failed' });
        }
        console.log('File saved:', filePath);
        io.to(to).emit('receive-file', {
          from: socket.user.id,
          type,
          filePath,
          timestamp: new Date(),
        });
      });
    });

    socket.on('disconnect', () => {
      console.log('User disconnected:', socket.user.id);
    });
  });

  ioInstance = io;
  return io;
}

module.exports = function(server) {
  initSocket(server);
};
