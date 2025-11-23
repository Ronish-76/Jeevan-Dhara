import mongoose from 'mongoose';

const mongoUri = process.env.MONGO_URI;

export const connectDB = async () => {
  if (!mongoUri) {
    throw new Error('Missing MONGO_URI environment variable');
  }

  try {
    await mongoose.connect(mongoUri, {
      autoIndex: true,
    });
    console.log('MongoDB connected');
  } catch (error) {
    console.error('MongoDB connection error:', error.message);
    throw error;
  }
};

export const disconnectDB = async () => {
  await mongoose.connection.close();
};

