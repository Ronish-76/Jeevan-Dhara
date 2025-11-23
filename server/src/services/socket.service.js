import { Server } from 'socket.io';

let ioInstance = null;

export const initSocketServer = (httpServer) => {
  ioInstance = new Server(httpServer, {
    cors: {
      origin: process.env.SOCKET_ALLOWED_ORIGINS?.split(',') || '*',
    },
  });

  ioInstance.on('connection', (socket) => {
    socket.on('disconnect', () => {
      // reserved for logging / metrics
    });
  });

  return ioInstance;
};

export const emitRequestCreated = (payload) => {
  if (ioInstance) {
    ioInstance.emit('request:new', payload);
  }
};

export const emitRequestResponded = (payload) => {
  if (ioInstance) {
    ioInstance.emit('request:responded', payload);
  }
};
