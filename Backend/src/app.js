const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes');
const { errorHandler } = require('./utils/errorHandler');
const admin = require('firebase-admin');
const serviceAccount = require('../service-account-file.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Make admin accessible globally or export it
global.firebaseAdmin = admin;
const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/v1', apiRoutes);

app.use(errorHandler);

module.exports = app;
