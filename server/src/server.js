import 'dotenv/config';
import http from 'http';
import app from './app.js';
import { connectDB } from './config/db.js';
import { initSocketServer } from './services/socket.service.js';

const port = process.env.PORT || 5000;

const start = async () => {
  try {
    await connectDB();

    const server = http.createServer(app);
    initSocketServer(server);

    server.listen(port, '0.0.0.0', () => {
      console.log(`Server running on http://0.0.0.0:${port}`);
      console.log(`Accessible from Android emulator at http://10.0.2.2:${port}`);
    });
  } catch (error) {
    console.error('Failed to start server', error);
    process.exit(1);
  }
};

start();
