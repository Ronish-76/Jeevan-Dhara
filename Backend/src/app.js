const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes');
const { errorHandler } = require('./utils/errorHandler');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/v1', apiRoutes);

app.use(errorHandler);

module.exports = app;